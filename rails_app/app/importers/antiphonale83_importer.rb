# Imports chants from the directory structure of Antiphonale 1983
# https://github.com/igneus/antiphonale83
class Antiphonale83Importer < BaseImporter
  def call(path)
    # only import Psalter antiphons, the rest is too small to be worth importing
    Dir["#{path}/psalterium/*.gly"].each {|f| import_file f, path }
  end

  def import_file(path, dir)
    in_project_path =
      path
        .sub(dir, '')
        .sub(%r{^/}, '')

    book = Book.find_by_system_name! 'oco1983'
    cycle = Cycle.find_by_system_name! 'psalter'
    language = SourceLanguage.find_by_system_name! 'gabc'

    scores = Gly::Parser.new.parse(path).scores

    scores.each do |s|
      if s.headers['id'].blank?
        puts 'score ID missing, skip'
        next
      end

      puts in_project_path + '#' + s.headers['id']

      import_score s, in_project_path, book, cycle, corpus, language
    end
  end

  def import_score(score, in_project_path, book, cycle, corpus, language)
    header = score.headers # TODO: .transform_values {|v| v == '' ? nil : v }
    lyrics = score.lyrics

    chant = Chant.find_or_initialize_by(chant_id: header['id'], source_file_path: in_project_path)

    chant.corpus = corpus
    chant.book = book
    chant.cycle = cycle
    chant.hour = detect_hour header, in_project_path
    chant.source_language = language
    chant.genre = detect_genre header, in_project_path

    # Import not the original gly source code, but transformed to gabc,
    # in order to make subsequent processing as simple as possible
    # (no need to add support for another source code language)
    chant.source_code = score_to_gabc score

    chant.lyrics =
      LyricsHelper
        .normalize_initial(lyrics.readable)
        .gsub(%r{\s*<sp>V\.</sp>\s*}, ' ')
    chant.header = header.instance_variable_get :@headers # only last value for each repeated key!

    last_annotation = header.each_value('annotation').to_a.last
    chant.modus, chant.differentia =
      if chant.genre.system_name == 'responsory_short'
        last_annotation.split(' ')[-1..-1]
      else
        last_annotation.split(' ')
      end

    chant.syllable_count = lyrics.each_syllable.select {|i| i != '*' }.size
    chant.word_count = lyrics.each_word.select {|i| i.readable != '*' }.size
    # # TODO: chant.melody_section_count

    chant.save!
  rescue
    p score
    raise
  end

  private

  def detect_genre(header, path)
    annotation = header['annotation']

    genre =
      if path =~ /responsoria/
        'responsory_short'
      elsif annotation =~ /ad (Ben|Mag)/
        'antiphon_gospel'
      else
        'antiphon'
      end

    Genre.find_by_system_name!(genre)
  end

  def detect_hour(header, path)
    id = header['id']

    hour =
      case path
      when /completorium/
        'compline'
      else
        nil
      end

    hour ||=
      case id
      when /^ol/
        'readings'
      when /^l/
        'lauds'
      when /^m/
        'daytime'
      when /^v/
        'vespers'
      else
        nil
      end

    hour && Hour.find_by_system_name!(hour)
  end

  def delete_image(chant)
    puts "deleting image of #{chant.fial_of_self}"
    path = LilypondImageGenerator.image_path chant
    File.delete path if File.exist? path
  end

  def score_to_gabc(gly_score)
    Gly::GabcConvertor
      .new
      .convert(gly_score)
      .string
  end
end
