# coding: utf-8
class GregobaseImporter < BaseImporter
  include GabcImporter

  GENRES = {
    'an' => 'antiphon',
    're' => 'responsory_nocturnal',
    'rb' => 'responsory_short',
  }.freeze

  def call(_)
    @source_language = SourceLanguage.find_by_system_name! 'gabc'

    corpus.imports.build.do! do |import|
      sources.each {|source| import_source(source, import) }
    end

    report_unseen_chants
    report_unimplemented_attributes
  end

  def import_source(source, import)
    music_book = MusicBook.find_or_create_by!(
      corpus: corpus,
      title: source.title,
      publisher: source.editor,
      year: source.year
    )

    source
      .gregobase_chant_sources
      .joins(:gregobase_chant)
      .where(gregobase_chants: {'office-part': GENRES.keys})
      .where.not(gregobase_chants: {gabc: ''})
      .each {|i| import_chant music_book, i, import }
  end

  def import_chant(music_book, chant_source, import)
    gchant = chant_source.gregobase_chant

    return if gchant.gabc.start_with? '['

    # if the 'name' header is not provided, gregorio prints a warning when processing the score
    name = "name: #{gchant.incipit};\n"
    nabc_lines = gchant.gabc.include?('|') ? "nabc-lines: 1;\n" : ''
    source = JSON.parse(gchant.gabc)
    source = name + nabc_lines + "%%\n" + source unless source =~ /^%%\r?$/

    return if source.scan('(::)').size > 8

    begin
      score = MyGabcParser.call source
    rescue => e
      STDERR.puts source
      STDERR.puts "failed to parse '#{gchant.id}': #{e.message}"
      return
    end

    # This is important, gchant.id alone would not suffice.
    # In the GregoBase DB model single chant often belongs to
    # several different sources, while we import each such occurrence
    # as separate chant.
    # (And we want it like this, because, while the music is the same,
    # characteristics like Cycle, Season etc. often vary.)
    fake_path = "#{chant_source.source}/#{gchant.id}"

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: fake_path)
    chant.corpus = corpus # not a duplicate, find_or_initialize_by doesn't infer any values from the relation when initializing
    chant.import = import
    chant.source_language = @source_language

    chant.music_book = music_book
    chant.gregobase_chant_id = gchant.id

    adapter = Adapter.new(chant_source, score, music_book, source)
    update_chant_from_adapter(chant, adapter)

    chant.save!
  end

  # selects sources for import
  def sources
    Gregobase::GregobaseSource
      .all
      .collect do |s|
      import = s.title =~ /(antiphonale|antiphonarium|antiphonarius|completorium|hebdomad|les heures|liber hymnarius|matutinum|nocturnale|nocturnalis|psalterium|semaine|usualis|graduale simplex|et responsoria)/i
      puts "#{import ? '+' : '-'} #{s.title} (#{s.year})"

      import ? s : nil
    end
      .compact
  end

  class Adapter < BaseImportDataAdapter
    extend Forwardable

    # @param gregobase_chant_source [Gregobase::GregobaseChantSource]
    def initialize(gregobase_chant_source, score, music_book, source_code)
      @chant = gregobase_chant_source.gregobase_chant
      @source = gregobase_chant_source.gregobase_source
      @score = score
      @music_book = music_book
      @source_code = source_code

      @score_with_stats = GabcScoreStats.new(score)
    end

    attr_reader :source_code
    def_delegators :@score_with_stats, :syllable_count, :word_count, :melody_section_count

    def book
      Book.find_by_system_name! detect_book @music_book
    end

    def genre
      GENRES[@chant.public_send('office-part')]
        .yield_self {|g| (g == 'antiphon' && source_code.include?('<sp>V/</sp>')) ? 'antiphon_standalone' : g }
        .yield_self {|g| Genre.find_by_system_name! g }
    end

    def lyrics
      lyrics_common_base
        .then(&LyricsHelper.method(:normalize_initial))
        .gsub(%r{\s*<sp>[VR]/</sp>\.?\s*}, ' ')
    end

    def lyrics_normalized
      lyrics_common_base
        .gsub(%r{\s*<sp>([VR])/</sp>\.?\s*}) {|m| Regexp.last_match[1] == 'V' ? ' | ' : ' ' }
        .gsub(%r{\s*<i>.*?</i>\s*}, ' ')
        .yield_self {|l| l[0 ... l.rindex('Glória Patri')] }
        .yield_self {|l| LyricsNormalizer.new.normalize_latin l }
    end

    def alleluia_optional
      false # TODO
    end

    def header
      {}
    end

    def modus
      modus_differentia[0]
    end

    def differentia
      modus_differentia[1]
    end

    private

    def lyrics_common_base
      @score.music.lyrics_readable
        .strip
        .gsub(%r{\s*<eu>.*?</eu>}, '')
        .then(&LyricsHelper.method(:remove_euouae))
        .gsub(%r{<sp>[*+]</sp>}, '')
        .then(&GabcLyricsHelper.method(:decode_special_characters))
        .gsub('<sp>\P</sp>', '')
        .gsub(%r{<v>.*?</v>}, '')
        .then(&GabcLyricsHelper.method(:remove_attached_text))
    end

    def modus_differentia
      diff = @chant.mode_var.present? ? @chant.mode_var : nil

      mode =
        case @chant.mode
        when '0'
          nil
        when /^\d+$/
          RomanNumerals.to_roman @chant.mode.to_i
        when 'p'
          'per'
        when nil, ''
          if @chant.mode_var =~ /^[IV]+/
            mode, diff = @chant.mode_var.split(' ', 2)
            mode
          else
            diff = nil
            @chant.mode_var
          end
        else
          @chant.mode
        end

      mode&.sub!(/^t.\s+/, '')
      mode&.sub!(/^per$/i, &:downcase)
      mode&.sub!(/^[cde]$/i, &:upcase)
      mode&.sub!(/^(irreg)\.$/, '\1')

      diff&.sub!(/trans(p(os)?)?/i, 'tr')

      [mode, diff]
    end

    def detect_book(music_book)
      before_loth = ->(i) { i < 1971 }
      after_loth = ->(i) { i >= 1971 }

      case music_book.attributes.symbolize_keys # pattern matching doesn't seem to work for Hashes with String keys
      in {title: /Liber Usualis/} |
        {title: /Antiphonale Romanum/, year: ^before_loth} |
        {title: /Antiphonale Marcianum/} |
        {title: /Liber antiphonarius/, year: ^before_loth} |
        {title: /Nocturnale Romanum/} |
        {title: /Liber nocturnalis/, year: ^before_loth} |
        {title: /Semaine Sainte/, year: ^before_loth}
        'br'
      in {title: /Antiphonale Monasticum/, year: ^before_loth} |
        {title: /Cod. Sang. 39[01]/} # by a little cheat let's consider the monastic liturgy one and unchanging in time and space, for our purposes it's OK
        'bm'
      in {title: /monasticum/i, year: ^after_loth}
        'lhm'
      in {publisher: 'Dominican'}
        'bsop'
      in {title: /Antiphonarium Cisterciense/, year: ^before_loth}
        'bcist'
      in {title: /Antiphonale Romanum/, publisher: 'Solesmes', year: ->(i) { i > 2000 }} |
        {title: /Antiphon. et Responsoria/} |
        {title: /Les Heures Grégoriennes/} # LHG don't match the OCO2015 (by far) 100%, but I don't want to introduce a new Book just for them
        'oco2015'
      in {title: 'Liber Hymnarius', publisher: 'Solesmes'}
        'oco1983'
      in {title: 'Graduale simplex'}
        'gs'
      end
    end
  end
end
