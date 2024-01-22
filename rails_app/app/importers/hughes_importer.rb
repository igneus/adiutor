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

    mei = File.read path

    begin
      txt_path = path.sub(/\.mei$/, '.txt')
      txt = File.read txt_path
    rescue Errno::ENOENT
      STDERR.puts "#{txt_path.inspect} not found, skipping"
      return
    end

    adapter = Adapter.new(mei, txt, book, path.sub(dir + '/', ''))

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: path)

    chant.corpus = corpus
    chant.import = import
    chant.source_language = source_language

    update_chant_from_adapter chant, adapter

    chant.save!
  end

  class Adapter < BaseImportDataAdapter
    extend Forwardable

    def initialize(mei, txt, book, path)
      @source_code = mei
      @txt = txt
      @book = book
      @path = path
    end

    # overriding parent methods
    attr_reader :book, :source_code

    find_associations_by_system_name :cycle, :hour, :genre

    def cycle_system_name
      'sanctorale'
    end

    def genre_system_name
      'antiphon'
    end

    def hour_system_name
      case File.basename(File.dirname(@path))
      when 'Matins'
        'readings'
      when 'Lauds'
        'lauds'
      when /Vespers/
        'vespers'
      else
        STDERR.puts "Failed to detect hour from path #{@path.inspect}"
        nil
      end
    end

    def lyrics
      @txt
        .yield_self {|x| x[x.index('/') .. x.index('/()')] }
        .gsub('/', '')
        .strip
        .gsub(/\s+/m, ' ')
    end

    def lyrics_normalized
      LyricsNormalizer.new.normalize_latin lyrics
    end

    def word_count
      lyrics.split(/\s+/).size
    end
  end
end
