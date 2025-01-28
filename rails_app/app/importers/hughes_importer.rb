# Imports chants from the directory structure of the Andrew Hughes chant corpus
# https://github.com/DDMAL/Andrew-Hughes-Chant
class HughesImporter < BaseImporter
  def build_common_attributes
    {
      book: Book.find_by_system_name!('other'),
      source_language: SourceLanguage.find_by_system_name!('mei'),
    }
  end

  def do_import(common_attributes, path)
    music_dir = File.join path, 'file_structure_text_file_MEI_file'

    Dir["#{music_dir}/**/*.mei"]
      .each {|f| import_file f, music_dir, common_attributes }
  end

  def import_file(path, dir, common_attributes)
    p path
    in_project_path = path.sub(dir + '/', '')

    mei = File.read path
    txt =
      begin
        File.read path.sub(/\.mei$/, '.txt')
      rescue Errno::ENOENT
        STDERR.puts 'txt file not found'
        ''
      end
    adapter = Adapter.new(mei, in_project_path, txt)

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: in_project_path)

    update_chant_from_adapter chant, adapter
    chant.assign_attributes common_attributes

    chant.save!
  end

  class Adapter < BaseImportDataAdapter
    include MeiAdapter

    def initialize(source_code, path, txt)
      # dirty hack: the MEI files miss staff@n attributes without which
      # music21 is unable to load them
      @source_code = source_code.gsub('<staff ', '<staff n="1" ')

      @path = path
      @txt = txt

      @xml_doc = Nokogiri::XML(@source_code)
    end

    # overriding parent methods
    attr_reader :source_code

    find_associations_by_system_name :cycle, :season, :hour, :genre

    def header
      @header ||=
        @xml_doc
          .xpath('/m:mei/m:meiHead/m:extMeta', 'm' => MEI_XML_NAMESPACE)
          .collect(&:text)
          .reject {|i| i.nil? || i.empty? }
          .flat_map {|i| i.split('###') }
          .collect {|i| i.split(/\s*:\s*/, 2) }
          .to_h
          .merge('txt_meta' => txt_meta)
          .transform_values {|v| v == '' ? nil : v }
    end

    def modus
      header['mode']&.yield_self do |x|
        if x =~ /^\d+$/
          RomanNumerals.to_roman x.to_i
        else
          x
        end
      end
    end

    def differentia
      header['final']
    end

    def cycle_system_name
      if season_system_name
        'temporale'
      else
        'sanctorale'
      end
    end

    def season_system_name
      case header['saint']
      when /Adv\./
        'advent'
      when /=Epi(\.[Oov])?$/, /=Nat/, /=Cir$/
        'christmas'
      when /XL\.\d/
        'lent'
      when /Pas\.\d/, /=Pas=/, /Pen\./, /=Pen=/
        'easter'
      when /=Epi\.\d/, /=LX{0,2}$/, /Corpus_Christi/i, /Trinity/i, /Tri\./, /(Aug|Sep|Oct|Nov)/
        'ordinary'
      end
    end

    def genre_system_name
      begin
        txt_meta \
        &&
        case txt_meta['genre']
        when 'I'
          'invitatory'
        when 'A'
          if txt_meta['position'] == 'E'
            'antiphon_gospel'
          else
            'antiphon'
          end
        when 'E'
          'antiphon_gospel'
        when 'R', 'V'
          if %w(T S N).include? txt_meta['hour']
            'responsory_short'
          else
            'responsory_nocturnal'
          end
        else
          nil
        end
      end \
      ||
      begin
        STDERR.puts 'failed to parse'
        'varia' # fake
      end
    end

    def hour_system_name
      hour_name =
        header['office'] ||
        File.basename(File.dirname(@path))

      case hour_name
      when 'Matins'
        'readings'
      when 'Lauds'
        'lauds'
      when /Vespers/
        'vespers'
      else
        STDERR.puts "Failed to detect hour: office #{header['office'].inspect}, path #{@path.inspect}"
        nil
      end
    end

    def lyrics
      header['lyrics'].strip
    end

    def lyrics_normalized
      LyricsNormalizer.new.normalize_latin lyrics
    end

    private

    def txt_meta
      @txt_meta ||=
        @txt.lines[0]
          &.match(/\|[\w\d]*?=(?<hour>\w)(?<genre>\w)(?<position>[\w\d]*)(\.(?<mode>[\w\d]+))?/)
          &.named_captures
    end
  end
end
