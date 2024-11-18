# Functionality shared by import adapters for MEI-based corpora
module MeiAdapter
  MEI_XML_NAMESPACE = 'http://www.music-encoding.org/ns/mei'

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
end