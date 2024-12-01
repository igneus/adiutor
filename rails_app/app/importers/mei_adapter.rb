# Functionality shared by import adapters for MEI-based corpora
module MeiAdapter
  MEI_XML_NAMESPACE = 'http://www.music-encoding.org/ns/mei'

  def lyrics
    mei_syllables
      .collect {|s| s.text + (s[:wordpos].yield_self {|x| x == 't' || x == 's' || x.nil? } ? ' ' : '') }
      .join
      .strip
  end

  # duplicate code, with HughesImporter
  def syllable_count
    @syllable_count ||= mei_syllables.size
  end

  private

  def mei_syllables
    @xml_doc.xpath('//m:syl', 'm' => MEI_XML_NAMESPACE)
  end
end