# Imports chants encoded by the "Echoes from the Past" project
# https://github.com/ECHOES-from-the-Past/GABCtoMEI
class EchoesImporter < BaseImporter
  def build_common_attributes
    {
      book: Book.find_by_system_name!('other'),
      source_language: SourceLanguage.find_by_system_name!('mei'),
    }
  end

  def do_import(common_attributes, path)
    Dir["#{path}/MEI_outfiles/antiphonae_*/*.mei"].each {|f| import_file f, path, common_attributes }
  end

  def import_file(path, dir, common_attributes)
    p path

    in_project_path =
      path
        .sub(dir, '')
        .sub(%r{^/}, '')

    adapter = Adapter.new(File.read(path), in_project_path)
    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: in_project_path)

    update_chant_from_adapter chant, adapter
    chant.assign_attributes common_attributes

    chant.save!
  end

  class Adapter < BaseImportDataAdapter
    include MeiAdapter

    def initialize(source_code, path)
      @source_code = source_code
      @path = path

      @dirname = File.dirname path
      @xml_doc = Nokogiri::XML(@source_code)
    end

    attr_reader :source_code

    find_associations_by_system_name :cycle, :genre, :hour

    def cycle_system_name
      if @dirname.include? 'feriale'
        'psalter'
      end
    end

    def genre_system_name
      case @dirname
      when /magnificat/
        'antiphon_gospel'
      when /feriale/
        'antiphon_psalter'
      else
        'antiphon'
      end
    end

    def hour_system_name
      if @dirname.include? 'magnificat'
        'vespers'
      end
    end

    def lyrics_normalized
      LyricsNormalizer.new.normalize_latin lyrics
    end
  end
end
