# Imports chants from the directory structure of Liber antiphonarius 1960
# transcribed by Andrew Hinkley
# https://github.com/ahinkley/liber-antiphonarius-1960
class LiberAntiphonariusImporter
  def call(path)
    %w(AN RE)
      .flat_map {|genre| Dir["#{path}/#{genre}/**/*.gabc"] }
      .each {|f| import_file f, path }
  end

  def import_file(path, dir)
    p path
    in_project_path = path.sub(dir, '').sub(/^\//, '')

    book = Book.find_by_system_name! 'la1960'
    corpus = Corpus.find_by_system_name! 'la1960'
    language = SourceLanguage.find_by_system_name! 'gabc'

    source = File.read path
    score = parse source
    header = score.header.to_hash
    page = page_from_header_book header['book']

    cycle = cycle_by_page(page)
    season = season_by_page(page)

    chant = Chant.find_or_initialize_by(chant_id: '1', source_file_path: in_project_path)

    chant.corpus = corpus
    chant.book = book
    chant.cycle = cycle
    chant.season = season
    chant.source_language = language

    chant.source_code = source
    # chant.lyrics = score.lyrics_readable
    chant.header = header

    chant.modus = RomanNumerals.to_roman header['mode'].to_i
    # %w[quid differentia psalmus placet fial].each do |key|
    #   chant.public_send "#{key}=", header[key]
    # end
    #
    # %i[syllable_count word_count melody_section_count].each do |property|
    #   chant.public_send "#{property}=", score_with_stats.public_send(property)
    # end

    chant.save!
  end

  def parse(source)
    GabcParser.new.parse(source) || raise("failed to parse: #{source}")
  end

  def page_from_header_book(value)
    value.match(/.+?, pp (\d+)/) {|m| m[1].to_i } || raise("page not found in #{value.inspect}")
  end

  def cycle_by_page(page)
    # TODO
    Cycle.find_by_system_name! 'temporale'
  end

  def season_by_page(page)
    # TODO
    Season.find_by_system_name! 'ordinary'
  end
end
