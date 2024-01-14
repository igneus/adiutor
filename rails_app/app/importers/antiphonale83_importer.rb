# coding: utf-8
# Imports chants from the directory structure of Antiphonale 1983
# https://github.com/igneus/antiphonale83
class Antiphonale83Importer < BaseImporter
  def call(path)
    corpus.imports.build.do! do |import|
      # only import Psalter antiphons, the rest is too small to be worth importing
      Dir["#{path}/psalterium/*.gly"].each {|f| import_file f, path, import }
    end

    report_unseen_chants
    report_unimplemented_attributes
  end

  def import_file(path, dir, import)
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

      import_score s, in_project_path, book, cycle, corpus, language, import
    end
  end

  def import_score(score, in_project_path, book, cycle, corpus, language, import)
    chant = corpus.chants.find_or_initialize_by(
      chant_id: score.headers['id'],
      source_file_path: in_project_path
    )

    chant.corpus = corpus
    chant.import = import
    chant.source_language = language

    # Import not the original gly source code, but transformed to gabc,
    # in order to make subsequent processing as simple as possible
    # (no need to add support for another source code language)
    gabc = score_to_gabc score

    gabc_score = nil
    begin
      gabc_score = MyGabcParser.call(gabc)
    rescue RuntimeError => e
      STDERR.puts "failed to parse gabc for '#{in_project_path}' ##{chant.id}: #{e.message}"
    end

    adapter = Adapter.new score, gabc_score, gabc, in_project_path, book, cycle
    update_chant_from_adapter chant, adapter

    chant.save!
  rescue
    p score
    raise
  end

  private

  def score_to_gabc(gly_score)
    Gly::GabcConvertor
      .new
      .convert(gly_score)
      .string
  end

  class Adapter < BaseImportDataAdapter
    def initialize(score, gabc_score, gabc, in_project_path, book, cycle)
      @score = score
      @gabc_score = gabc_score
      @in_project_path = in_project_path
      @book = book
      @cycle = cycle

      @score_with_stats = gabc_score && GabcScoreStats.new(gabc_score)
      @gabc = gabc
    end

    attr_reader :score, :in_project_path, :gabc

    # overriding parent methods
    attr_reader :book, :cycle
    alias source_code gabc

    find_associations_by_system_name :hour, :genre

    def hour_system_name
      id = score.headers['id']

      hour =
        case in_project_path
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

      hour
    end

    def genre_system_name
      annotation = score.headers['annotation']

      if in_project_path =~ /responsoria/
        'responsory_short'
      elsif annotation =~ /ad (Ben|Mag)/
        'antiphon_gospel'
      else
        'antiphon'
      end
    end

    def lyrics
      LyricsHelper
        .normalize_initial(score.lyrics.readable)
        .gsub(%r{\s*<sp>V\.</sp>\s*}, ' ')
    end

    def lyrics_normalized
      score.lyrics.readable
        .gsub(%r{\s*<sp>V\.</sp>\s*}, ' | ')
        .gsub(%r{\s*<i>.*?</i>\s*}, ' ')
        .yield_self {|l| l[0 ... l.rindex('| Glória Patri')] }
        .yield_self {|l| LyricsNormalizer.new.normalize_latin l }
    end

    def alleluia_optional
      !!(score.lyrics.readable =~ /T\.\s*P\./)
    end

    def header
      score.headers.instance_variable_get :@headers # only last value for each repeated key!
    end

    def modus
      modus_differentia[0]
        &.sub(/^(per)\.$/, '\1')
    end

    def differentia
      modus_differentia[1]
    end

    # Forwardable cannot be used, because @score_with_stats may be unavailable
    %i(syllable_count word_count melody_section_count).each do |m|
      define_method m do
        @score_with_stats&.public_send(m)
      end
    end

    private

    def modus_differentia
      last_annotation = score.headers.each_value('annotation').to_a.last
      if genre.system_name == 'responsory_short'
        last_annotation.split(' ')[-1..-1]
      else
        last_annotation.split(' ')
      end
    end
  end
end
