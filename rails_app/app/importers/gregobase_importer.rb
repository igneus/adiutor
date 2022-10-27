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
    p gchant

    return if gchant.gabc.start_with? '['

    nabc_lines = gchant.gabc.include?('|') ? "nabc-lines: 1;\n" : ''
    source = JSON.parse(gchant.gabc)
    source = nabc_lines + "%%\n" + source unless source =~ /^%%\r?$/

    return if source.scan('(::)').size > 8

    begin
      score = SimpleGabcParser.call source
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

    chant = corpus.chants.find_or_initialize_by(chant_id: '1', source_file_path: fake_path)
    chant.corpus = corpus # not a duplicate, find_or_initialize_by doesn't infer any values from the relation when initializing
    chant.import = import
    chant.gregobase_chant_id = gchant.id

    chant.book = Book.find_by_system_name! detect_book music_book
    chant.music_book = music_book
    chant.source_language = @source_language

    genre = GENRES[gchant.public_send('office-part')]
    genre = 'antiphon_standalone' if genre == 'antiphon' && source.include?('<sp>V/</sp>')
    chant.genre = Genre.find_by_system_name! genre

    chant.source_code = source

    lyrics_common_base =
      score.music.lyrics_readable
        .strip
        .gsub(%r{\s*<eu>.*?</eu>}, '')
        .then(&LyricsHelper.method(:remove_euouae))
        .gsub(%r{<sp>[*+]</sp>}, '')
        .gsub(%r{<sp>([ao]e)</sp>}) { Regexp.last_match[1] }
        .gsub(%r{<sp>'([ao])e</sp>}) { Regexp.last_match[1] + 'é' }
        .gsub("<sp>'æ</sp>", 'aé')
        .gsub("<sp>'œ</sp>", 'oé')
        .gsub('<sp>\P</sp>', '')
        .gsub(%r{<v>.*?</v>}, '')
    chant.lyrics =
      lyrics_common_base
        .then(&LyricsHelper.method(:normalize_initial))
        .gsub(%r{\s*<sp>[VR]/</sp>\.?\s*}, ' ')
    chant.lyrics_normalized =
      lyrics_common_base
        .gsub(%r{\s*<sp>([VR])/</sp>\.?\s*}) {|m| Regexp.last_match[1] == 'V' ? ' | ' : ' ' }
        .gsub(%r{\s*<i>.*?</i>\s*}, ' ')
        .yield_self {|l| l[0 ... l.rindex('Glória Patri')] }
        .yield_self {|l| LyricsNormalizer.new.normalize_latin l }
    chant.alleluia_optional = false # TODO
    chant.header = {}

    chant.modus, chant.differentia = modus_differentia gchant

    extract_stats(chant, score)
    chant.save!
  end

  def modus_differentia(gchant)
    diff = gchant.mode_var.present? ? gchant.mode_var : nil

    mode =
      case gchant.mode
      when '0'
        nil
      when /^\d+$/
        RomanNumerals.to_roman gchant.mode.to_i
      when 'p'
        'per'
      when nil, ''
        if gchant.mode_var =~ /^[IV]+/
          mode, diff = gchant.mode_var.split(' ', 2)
          mode
        else
          diff = nil
          gchant.mode_var
        end
      else
        gchant.mode
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
end
