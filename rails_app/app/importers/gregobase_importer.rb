# coding: utf-8
class GregobaseImporter < BaseImporter
  GENRES = {
    'an' => 'antiphon',
    're' => 'responsory_nocturnal',
    'rb' => 'responsory_short',
  }.freeze

  def call(_)
    @source_language = SourceLanguage.find_by_system_name! 'gabc'

    sources.each(&method(:import_source))
  end

  def import_source(source)
    music_book = MusicBook.find_or_create_by!(
      corpus: corpus,
      title: source.title,
      publisher: source.editor,
      year: source.year
    )

    source
      .gregobase_chant_sources
      .joins(:gregobase_chant)
      .where(gregobase_chants: {'office-part': %w(an rb re)})
      .where.not(gregobase_chants: {gabc: ''})
      .each {|i| import_chant music_book, i }
  end

  def import_chant(music_book, chant_source)
    gchant = chant_source.gregobase_chant
    p gchant

    return if gchant.gabc.start_with? '['

    source = "%%\n" + JSON.parse(gchant.gabc)

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
    chant.gregobase_chant_id = gchant.id

    chant.book = Book.find_by_system_name! detect_book music_book
    chant.music_book = music_book
    chant.source_language = @source_language
    chant.genre = Genre.find_by_system_name! GENRES[gchant.public_send('office-part')]

    chant.source_code = source
    chant.lyrics = score.music.lyrics_readable
    chant.lyrics_normalized = LyricsNormalizer.new.normalize_latin score.music.lyrics_readable
    chant.alleluia_optional = false # TODO
    chant.header = {}

    chant.modus, chant.differentia = modus_differentia gchant

    p chant
    chant.save!
  end

  def modus_differentia(gchant)
    diff = gchant.mode_var.present? ? gchant.mode_var : nil

    mode =
      case gchant.mode
      when /^\d+$/
        RomanNumerals.to_roman gchant.mode.to_i
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
    in {title: 'Graduale simplex'}
      'gs'
    end
  end

  # selects sources for import
  def sources
    Gregobase::GregobaseSource
      .all
      .collect do |s|
      import = s.title =~ /(antiphonale|antiphonarium|antiphonarius|hebdomad|les heures|nocturnale|nocturnalis|psalterium|semaine|usualis|graduale simplex|et responsoria)/i
      puts "#{import ? '+' : '-'} #{s.title} (#{s.year})"

      import ? s : nil
    end
      .compact
  end
end
