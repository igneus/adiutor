# Imports chants from the Neuma collection http://neuma.huma-num.fr/home/services
class NeumaImporter < BaseImporter
  def build_common_attributes
    {
      book: Book.find_by_system_name!('other'),
      source_language: SourceLanguage.find_by_system_name!('mei'),
    }
  end

  def do_import(common_attributes, path)
    # MEI files are expected to be downloaded in advance by `rake neuma:fetch`
    Dir[File.join(ENV['NEUMA_SOURCES_PATH'], "*")]
      .each do |f|
      next unless File.directory? f
      next unless f =~ /[\w\d]+/

      # downloaded MEI files contain no metadata at all, so we make an API
      # request for the chant listing and pair the files with API responses
      Neuma::Corpus.opera(File.basename(f)).each do |opus|
        local_file = File.join f, "#{opus.ref}.xml"
        next unless File.exist? local_file

        import_file local_file, opus, common_attributes
      end
    end
  end

  def import_file(path, api_resource, common_attributes)
    puts path

    mei = File.read path

    adapter = Adapter.new(mei, api_resource, File.basename(path))
    return if adapter.genre_system_name.nil?

    chant = corpus.chants.find_or_initialize_by(chant_id: DEFAULT_CHANT_ID, source_file_path: File.basename(path))

    update_chant_from_adapter chant, adapter
    chant.assign_attributes common_attributes

    chant.save!
  end

  class Adapter < BaseImportDataAdapter
    # duplicate code, see HughesImporter
    MEI_XML_NAMESPACE = 'http://www.music-encoding.org/ns/mei'

    def initialize(source_code, api_resource, path)
      @source_code =
        source_code
          .gsub(' label="MusicXML Part"', '') # remove ugly staff label
          .gsub(' clef.shape="C"', ' clef.shape="G"') # make the clef a violin clef, as it's much more convenient to read
          .gsub(/ clef.line="\d"/, ' clef.line="2"')

      @api_resource = api_resource

      @xml_doc = Nokogiri::XML(@source_code)
    end

    attr_reader :source_code
    find_associations_by_system_name :genre

    def header
      @api_resource.to_h
    end

    def genre_system_name
      case @api_resource.title
      when /invitatorium/i
        'invitatory'
      when /antiphona/i
        'antiphon'
      when /(psalmus|cantique|versus)/i
        'varia'
      when /responsorium breve/i
        'responsory_short'
      when /responsorium prolixum/i
        'responsory_nocturnal'
      end
    end

    def lyrics
      @xml_doc
        .xpath('//m:syl', 'm' => MEI_XML_NAMESPACE)
        .collect {|s| s.text + (s[:wordpos].yield_self {|x| x == 't' || x.nil? } ? ' ' : '') }
        .join
        .strip
    end

    def word_count
      @xml_doc
        .xpath('//m:syl[@wordpos = "i" or not(@wordpos)]', 'm' => MEI_XML_NAMESPACE)
        .size
    end

    # duplicate code, with HughesImporter
    def syllable_count
      @syllable_count ||=
        @xml_doc
          .xpath('//m:syl', 'm' => MEI_XML_NAMESPACE)
          .size
    end

    def melody_section_count
      @xml_doc
        .xpath('//m:measure', 'm' => MEI_XML_NAMESPACE)
        .size
    end
  end
end
