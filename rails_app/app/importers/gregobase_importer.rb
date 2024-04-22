# coding: utf-8
class GregobaseImporter < BaseImporter
  include GabcImporter

  GENRES = {
    'an' => 'antiphon',
    're' => 'responsory_nocturnal',
    'rb' => 'responsory_short',
  }.freeze

  # value for Chant#source_file_path
  def self.fake_path(gregobase_chant_source)
    # chant.id alone would not suffice.
    # In the GregoBase DB model single chant often belongs to
    # several different sources, while we import each such occurrence
    # as separate chant.
    # (And we want it like this, because, while the music is the same,
    # characteristics like Cycle, Season etc. often vary.)

    "#{gregobase_chant_source.source_id}/#{gregobase_chant_source.chant_id}"
  end

  # which of the chant's (possibly) multiple chant_sources is considered
  # the main one?
  def self.main_chant_source(gregobase_chant)
    gregobase_chant
      .chant_sources
      .select {|i| to_be_imported? i.source }
      .sort_by {|i| [i.source_id, i.page] }
      .first
  end

  def self.to_be_imported?(gregobase_source)
    gregobase_source.title =~ /(antiphonale|antiphonarium|antiphonarius|completorium|hebdomad|in nocte|les heures|liber hymnarius|matutinum|nocturnale|nocturnalis|psalterium|semaine|usualis|graduale simplex|et responsoria|responsorialis)/i
  end

  def build_common_attributes
    {
      source_language: SourceLanguage.find_by_system_name!('gabc'),
    }
  end

  def do_import(common_attributes, _)
    sources.each {|source| import_source(common_attributes, source) }

    import_chants_without_source(common_attributes)
  end

  def import_source(common_attributes, source)
    music_book = MusicBook.find_or_create_by!(
      corpus: corpus,
      title: source.title,
      publisher: source.editor,
      year: source.year
    )

    source_attributes =
      common_attributes
        .merge(music_book: music_book)

    source
      .chant_sources
      .order(:page)
      .joins(:chant)
      .left_joins(chant: :tags)
      .where(gregobase_chants: {'office-part': GENRES.keys})
      .where.not(gregobase_chants: {gabc: ''})
      .each {|i| import_chant i, source_attributes }
  end

  def import_chants_without_source(common_attributes)
    music_book = MusicBook.find_or_create_by!(
      corpus: corpus,
      title: 'Liber fictus'
    )

    source_attributes =
      common_attributes
        .merge(music_book: music_book)

    Gregobase::Chant
      .without_source
      .left_joins(:tags)
      .where('office-part': GENRES.keys)
      .where.not(gabc: '')
      .each {|i| import_chant Gregobase::ChantSource.new(chant: i), source_attributes }
  end

  def import_chant(chant_source, common_attributes)
    gchant = chant_source.chant

    return if gchant.gabc.start_with? '['

    # not interested in vernacular adaptations
    tags = gchant.tags.collect &:tag
    return if tags.intersect? ['Annamitice', 'Graece', 'Sinnice']
    return if tags.find {|s| s =~ /English/i }

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

    fake_path = self.class.fake_path chant_source
    p fake_path

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: fake_path)

    chant.gregobase_chant_id = gchant.id

    adapter = Adapter.new(source, common_attributes[:music_book], chant_source, score)
    update_chant_from_adapter(chant, adapter)
    chant.assign_attributes common_attributes

    if chant.simple_copy?
      parent_chant_source = self.class.main_chant_source(gchant)
      parent_file_path = self.class.fake_path(parent_chant_source)
      begin
        chant.parent = corpus.chants.find_by_source_file_path!(parent_file_path)
      rescue ActiveRecord::RecordNotFound
        STDERR.puts "Failed to find Chant for #{parent_chant_source.inspect}, source_file_path #{parent_file_path.inspect}"
        p chant_source
        p parent_chant_source
        chant.parent = nil
      end
    else
      chant.parent = nil
    end

    chant.save!
  end

  # selects sources for import
  def sources
    Gregobase::Source
      .order(:id)
      .collect do |s|
      import = self.class.to_be_imported? s
      puts "#{import ? '+' : '-'} #{s.title} (#{s.year})"

      import ? s : nil
    end
      .compact
  end

  class Adapter < BaseImportDataAdapter
    # @param gregobase_chant_source [Gregobase::ChantSource]
    def initialize(source_code, music_book, gregobase_chant_source, score)
      @source_code = source_code
      @music_book = music_book

      @chant_source = gregobase_chant_source
      @chant = @chant_source.chant
      @source = @chant_source.source

      @score = score

      @score_with_stats = GabcScoreStats.new(score)
    end

    def_delegators :@score_with_stats, :syllable_count, :word_count, :melody_section_count

    # internal
    attr_reader :music_book

    # overriding parent methods
    attr_reader :source_code
    find_associations_by_system_name :book, :genre, :hour, :season, :cycle

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

    def copy
      # `@copy ||=` can't be used here, false is a valid cached value
      if @copy.nil?
        main_source = GregobaseImporter.main_chant_source(@chant)
        @copy = main_source.present? && !(@chant_source.same? main_source)
      end

      @copy
    end

    alias simple_copy copy

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

      if mode
        mode.sub!(/^t.\s+/, '')
        mode.sub!(/^per$/i, &:downcase)
        mode.sub!(/^[cde]$/i, &:upcase)
        mode.sub!(/^(irreg)\.$/, '\1')
      end

      if diff
        diff.downcase!
        diff.sub!(/tr(ans(p(os)?)?)?\.?/i, 'tr')

        diff.gsub!(/\s*([\*\d])\s*/, '\1') # no whitespace around an asterisk or a number
        diff.sub!(/^\*[\s-]*(.*)$/, '\1*') # leading asterisk => trailing asterisk
      end

      [mode, diff]
    end

    public

    def book_system_name
      before_loth = ->(i) { i < 1971 }
      after_loth = ->(i) { i >= 1971 }

      case music_book.attributes.symbolize_keys # pattern matching doesn't seem to work for Hashes with String keys
      in {title: /Liber Usualis/} |
        {title: /Antiphonale Romanum/, year: ^before_loth} |
        {title: /Antiphonale Marcianum/} |
        {title: /Liber antiphonarius/, year: ^before_loth} |
        {title: /Nocturnale Romanum/} |
        {title: /Liber nocturnalis/, year: ^before_loth} |
        {title: /Semaine Sainte/, year: ^before_loth} |
        {title: /In nocte nativitatis domini/i, year: ^before_loth}
        'br'
      in {title: 'Liber fictus'} # our fictive book used for chants unassigned to any source in GregoBase
        'br'
      in {title: /Antiphonale Monasticum/, year: ^before_loth} |
        {title: /Liber Responsorialis/, year: ^before_loth} |
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

    def genre_system_name
      g = GENRES[@chant.public_send('office-part')]

      if g == 'antiphon'
        if source_code.include?('<sp>V/</sp>')
          return 'antiphon_standalone'
        end

        if (music_book.title =~ /liber hymnarius/i || lyrics =~ /Ven[ií]te[\.,]?\Z/)
          return 'invitatory'
        end

        if @chant.tags.find {|t| t.tag =~ /invitatorium/i }
          return 'invitatory'
        end
      end

      g
    end

    def hour_system_name
      @chant.tags.find_yield do |t|
        case t.tag
        when /vesperas/i
          'vespers'
        when /laudes/i
          'lauds'
        when /ad (primam|tertiam|sextam|nonam)/i
          'daytime'
        when /(matutinum|vigilias|off\. lect\.)/i
          'readings'
        when /completorium/i
          'compline'
        end
      end
    end

    def season_system_name
      @chant.tags.find_yield do |t|
        case t.tag
        when /adventus/i
          CR::Seasons::ADVENT
        when /nativit.*? domini/i
          CR::Seasons::CHRISTMAS
        when /quadragesim/i, /hebdomad.*? sanct/i
          CR::Seasons::LENT
        when /pasch/i, /resurrectio/i
          CR::Seasons::EASTER
        end
        &.symbol
      end
    end

    def cycle_system_name
      return 'temporale' unless season_system_name.nil?

      @chant.tags.find_yield do |t|
        case t.tag
        when /^commune/i
          'sanctorale'
        end
      end
    end
  end
end
