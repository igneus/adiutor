# coding: utf-8
# Imports chants from the directory structure of Liber antiphonarius 1960
# transcribed by Andrew Hinkley
# https://github.com/ahinkley/liber-antiphonarius-1960
class LiberAntiphonariusImporter < BaseImporter
  def build_common_attributes
    {
      book: Book.find_by_system_name!('br'),
      source_language: SourceLanguage.find_by_system_name!('gabc')
    }
  end

  def do_import(common_attributes, path)
    %w(AN RE)
      .flat_map {|genre| Dir["#{path}/#{genre}/**/*.gabc"] }
      .each {|f| import_file f, path, common_attributes }
  end

  def import_file(path, dir, common_attributes)
    p path
    in_project_path = path.sub(dir, '').sub(/^\//, '')

    source = File.read path
    begin
      score = MyGabcParser.call source
    rescue RuntimeError => e
      STDERR.puts "failed to parse '#{path}': #{e.message}"
      return # just skip the failed score
    end

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: in_project_path)

    const_attributes = OpenStruct.new source_code: source
    adapter = Adapter.new(const_attributes, score)
    update_chant_from_adapter chant, adapter
    chant.assign_attributes common_attributes

    chant.save!
  end

  PageNumber = Struct.new(:number, :prefix, :suffix) do
    def in_range?(range, prefix=nil)
      self.prefix == prefix && range.include?(number)
    end
  end

  class Adapter < BaseImportDataAdapter
    def initialize(const_attributes, score)
      super(const_attributes)
      @score = score

      @score_with_stats = GabcScoreStats.new(score)
    end

    # internals
    attr_reader :score

    # overriding parent methods
    const_attributes :source_code
    def_delegators :@score_with_stats, :syllable_count, :word_count, :melody_section_count

    find_associations_by_system_name :cycle, :season, :genre

    def cycle_system_name
      if page.in_range?(1..209)
        'psalter'
      elsif page.in_range?(210..576)
        'temporale'
      elsif page.in_range?(577..931) || page.in_range?(1..141, '[')
        'sanctorale'
      elsif page.suffix == '*'
        'ordinarium'
      else
        'temporale' # TODO
      end
    end

    def season_system_name
      # here we pragmatically impose post-Vatican II notions of liturgical seasons,
      # since the material is being imported for purposes of comparison
      # with the vernacular chants for a post-Vatican II LOTH
      if page.in_range?(210..258)
        'advent'
      elsif page.in_range?(259..335)
        'christmas'
      elsif page.in_range?(336..340)
        'ordinary'
      elsif page.in_range?(341..431)
        'lent'
      elsif page.in_range?(432..447)
        'triduum'
      elsif page.in_range?(448..515)
        'easter'
      elsif page.in_range?(516..576)
        'ordinary'
      else
        nil
      end
    end

    def genre_system_name
      office_part = header['office-part']

      if office_part == 'Responsoria brevia'
        'responsory_short'
      elsif office_part == 'Antiphonae'
        # TODO: there is currently no easy and general way to detect gospel antiphons
        if cycle.system_name == 'psalter'
          'antiphon_psalter'
        else
          'antiphon'
        end
      else
        'varia'
      end
    end

    def lyrics
      score.music.lyrics_readable
        .strip
        .then(&LyricsHelper.method(:normalize_initial))
        .gsub(%r{\s*<sp>[VR]/</sp>\.?\s*}, ' ')
        .then(&GabcLyricsHelper.method(:remove_attached_text))
    end

    def lyrics_normalized
      score.music.lyrics_readable
        .gsub(%r{\s*<sp>([VR])/</sp>\.?\s*}) {|m| Regexp.last_match[1] == 'V' ? ' | ' : ' ' }
        .gsub(%r{\s*<i>.*?</i>\s*}, ' ')
        .yield_self {|l| l[0 ... l.rindex('Glória Patri')] }
        .yield_self {|l| LyricsNormalizer.new.normalize_latin l }
    end

    def header
      @header ||= score.header.to_hash.transform_values {|v| v == '' ? nil : v }
    end

    def modus
      header_mode = header['mode']

      case header_mode
      when nil
        nil
      when /^\d+$/
        RomanNumerals.to_roman(header_mode.to_i)
      when /^per/i
        header_mode
          .sub(/\.$/, '')
          .downcase
      else
        header_mode
      end
    end

    def alleluia_optional
      !!(score.music.lyrics_readable =~ /T\.\s*P\./)
    end

    private

    def page
      @page ||=
        header['book']
          .match(/.+?, pp (\[)?(\d+)(\*)?/) {|m| PageNumber.new(m[2].to_i, m[1], m[3]) } || raise("page not found in #{value.inspect}")
    end
  end
end
