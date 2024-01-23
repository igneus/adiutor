# Imports chants from the directory structure of the Nocturnale Romanum project
# https://github.com/Nocturnale-Romanum/nocturnale-romanum
class NocturnaleImporter < BaseImporter
  def call(path)
    book = Book.find_by_system_name! 'br'
    language = SourceLanguage.find_by_system_name! 'gabc'
    hour = Hour.find_by_system_name! 'readings'

    corpus.imports.build.do! do |import|
      Dir["#{path}/gabc/*.gabc"]
        .each {|f| import_file f, path, import, book, language, hour }
    end

    report_unseen_chants
    report_unimplemented_attributes
  end

  def import_file(path, dir, import, book, source_language, hour)
    return if path.include? 'sandhofe' # we already have these from GregoBase

    p path

    source = File.read path
    begin
      score = MyGabcParser.call source
    rescue RuntimeError => e
      STDERR.puts "failed to parse '#{path}': #{e.message}"
      return # just skip the failed score
    end

    adapter = Adapter.new(score, source, book, hour, path)
    return if adapter.genre_system_name == 'hymn'

    if adapter.genre_system_name.nil?
      STDERR.puts "failed to parse day code"
      return
    end

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: File.basename(path))

    chant.corpus = corpus
    chant.import = import
    chant.source_language = source_language

    update_chant_from_adapter chant, adapter

    chant.save!
  end

  class Adapter < BaseImportDataAdapter
    extend Forwardable

    def initialize(score, source_code, book, hour, path)
      @score = score
      @book = book
      @hour = hour
      @source_code = source_code

      @day_code = File.basename(path).split('.')[0].split('_')[0]

      header_mode = header['mode']
      case header_mode
      when /^(\d)(.*)$/
        @modus = RomanNumerals.to_roman $1.to_i
        @differentia = $2
      when /irreg/
        @modus =
          header_mode
            .sub(/\.$/, '')
            .downcase
      end

      @score_with_stats = GabcScoreStats.new(score)
    end

    # internals
    attr_reader :score

    # overriding parent methods
    attr_reader :book, :hour, :source_code, :modus, :differentia
    def_delegators :@score_with_stats, :syllable_count, :word_count, :melody_section_count

    find_associations_by_system_name :cycle, :season, :genre

    def cycle_system_name
      case @day_code
      when /^\d{4}/
        'sanctorale'
      when /^OR/
        'ordinarium'
      when /^(EX)?F\d/
        'psalter'
      else
        'temporale'
      end
    end

    def season_system_name
      case @day_code
      when /^A/
        'advent'
      when /^N/
        'christmas'
      when /^Q6F[5-7]/
        'triduum'
      when /^Q/
        'lent'
      when /^P/
        'easter'
      else
        if cycle_system_name == 'temporale'
          'ordinary'
        else
          nil
        end
      end
    end

    def genre_system_name
      @day_code.match(/([ARIH])\d?[ab]?$/) do |m|
        case m[1]
        when 'A'
          'antiphon'
        when 'R'
          'responsory_nocturnal'
        when 'I'
          'invitatory'
        when 'H'
          'hymn'
        end
      end
    end

    def lyrics
      score.music.lyrics_readable
    end

    def lyrics_normalized
      score.music.lyrics_readable
        .yield_self {|l| LyricsNormalizer.new.normalize_latin l }
    end

    def header
      @header ||= score.header.to_hash
    end
  end
end
