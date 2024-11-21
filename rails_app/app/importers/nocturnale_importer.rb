# Imports chants from the directory structure of the Nocturnale Romanum project
# https://github.com/Nocturnale-Romanum/nocturnale-romanum
class NocturnaleImporter < BaseImporter
  def build_common_attributes
    {
      book: Book.find_by_system_name!('br'),
      source_language: SourceLanguage.find_by_system_name!('gabc'),
      hour: Hour.find_by_system_name!('readings'),
    }
  end

  def do_import(common_attributes, path)
    Dir["#{path}/gabc/*.gabc"]
      .sort.reverse # so that "chantId_contributor.gabc" (contributor version) comes before "chantId.gabc" (selected version)
      .tap {|gabcs| create_music_books gabcs }
      .each {|f| import_file f, path, common_attributes }
  end

  def create_music_books(gabcs)
    ids = Set.new
    ids << 'selected'
    gabcs.each do |path|
      ids << contributor_id(path)
    end

    ids.each do |id|
      MusicBook.find_or_create_by!(
        corpus: corpus,
        title: id
      )
    end
  end

  def import_file(path, dir, common_attributes)
    return if path.include? 'sandhofe' # we already have these from GregoBase

    p path

    source = File.read path
    begin
      score = MyGabcParser.call source
    rescue RuntimeError => e
      STDERR.puts "failed to parse '#{path}': #{e.message}"
      return # just skip the failed score
    end

    adapter = Adapter.new(source, score, path)
    return if adapter.genre_system_name == 'hymn'

    if adapter.genre_system_name.nil?
      STDERR.puts "failed to parse day code '#{adapter.day_code}'"
      return
    end

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: File.basename(path))

    update_chant_from_adapter chant, adapter
    chant.assign_attributes common_attributes

    chant.music_book = corpus.music_books.find_by_title contributor_id(path)

    if is_main_file? path
      parent =
        corpus.chants
          .where(source_code: chant.source_code)
          .where("source_file_path LIKE '#{chant.source_file_path.sub(/\.gabc$/, '')}%'")
          .where.not(id: chant.id)
          .limit(1)
          .first

      if parent
        chant.parent = parent
        chant.copy = chant.simple_copy = true
      else
        chant.parent = nil
        chant.copy = chant.simple_copy = false
      end
    end

    chant.save!
  end

  def is_main_file?(path)
    !File.basename(path).include?('_')
  end

  def contributor_id(gabc_path)
    File.basename(gabc_path).split('.')[0].split('_')[1] || 'selected'
  end

  class Adapter < BaseImportDataAdapter
    def initialize(source_code, score, path)
      @source_code = source_code
      @score = score

      @day_code = File.basename(path).split('.')[0].split('_')[0]

      header_mode = header['mode']
      case header_mode
      when /^(\d)(.*)$/
        @modus = RomanNumerals.to_roman $1.to_i
        @differentia = $2 if $2.present?
      when /irreg/
        @modus =
          header_mode
            .sub(/\.$/, '')
            .downcase
      end

      @score_with_stats = GabcScoreStats.new(score)
    end

    # internals
    attr_reader :score, :day_code

    # overriding parent methods
    attr_reader :modus, :differentia, :source_code
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
          if cycle_system_name == 'psalter'
            'antiphon_psalter'
          else
            'antiphon'
          end
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
