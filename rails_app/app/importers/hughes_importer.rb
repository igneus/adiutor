# Imports chants from the directory structure of the Andrew Hughes chant corpus
# https://github.com/DDMAL/Andrew-Hughes-Chant
class HughesImporter < BaseImporter
  def call(path)
    book = Book.find_by_system_name! 'other'
    language = SourceLanguage.find_by_system_name! 'mei'

    music_dir = File.join path, 'file_structure_text_file_MEI_file'
    corpus.imports.build.do! do |import|
      Dir["#{music_dir}/**/*.mei"]
        .each {|f| import_file f, music_dir, import, book, language }
    end

    report_unseen_chants
    report_unimplemented_attributes
  end

  def import_file(path, dir, import, book, source_language)
    p path
    in_project_path = path.sub(dir + '/', '')

    mei = File.read path
    adapter = Adapter.new(mei, book, in_project_path)

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: in_project_path)

    chant.corpus = corpus
    chant.import = import
    chant.source_language = source_language

    update_chant_from_adapter chant, adapter

    chant.save!
  end

  class Adapter < BaseImportDataAdapter
    extend Forwardable

    def initialize(mei, book, path)
      # dirty hack: the MEI files miss staff@n attributes without which
      # music21 is unable to load them
      @source_code = mei.gsub('<staff ', '<staff n="1" ')

      @book = book
      @path = path
    end

    # overriding parent methods
    attr_reader :book, :source_code

    find_associations_by_system_name :cycle, :hour, :genre

    def header
      @header ||=
        Nokogiri::XML(@source_code)
          .xpath('/m:mei/m:meiHead/m:extMeta', 'm' => 'http://www.music-encoding.org/ns/mei')
          .collect(&:text)
          .reject {|i| i.nil? || i.empty? }
          .flat_map {|i| i.split('###') }
          .collect {|i| i.split(/\s*:\s*/, 2) }
          .to_h
    end

    def modus
      header['mode']&.yield_self {|x| RomanNumerals.to_roman x.to_i }
    end

    def differentia
      header['final']
    end

    def cycle_system_name
      'sanctorale'
    end

    def genre_system_name
      'antiphon'
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

    def word_count
      lyrics.split(/\s+/).size
    end
  end
end
