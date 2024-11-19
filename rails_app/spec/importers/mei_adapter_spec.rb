describe MeiAdapter do
  def xml_with_syls(*syls)
    <<~EOS
    <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="5.0">
    <!-- meiHead left out -->
    <music>
      <body>
        <mdiv>
          <score>
            <scoreDef>
              <staffGrp>
                <staffDef lines="5" n="1" notationtype="neume" />
              </staffGrp>
            </scoreDef>
            <section>
              <staff n="1">
                <layer>
                  <clef shape="F" line="3" xml:id="m-57a8344c-90a3-11ef-9c51-f2b2e3f0b574"/>
                  #{ syls.collect {|s| '<syllable>' + s + '</syllable>'}.join('') }
  </layer></staff></section></score></mdiv></body></music></mei>
    EOS
  end

  subject do
    Class.new do
      include MeiAdapter

      def initialize(doc)
        @xml_doc = doc
      end
    end.new(doc)
  end

  let(:doc) {Nokogiri::XML(xml) }

  describe 'single syllable' do
    let(:xml) { xml_with_syls '<syl>La</syl>' }
    it { expect(subject.lyrics).to eq 'La' }
  end

  describe 'two syllables, one word' do
    let(:xml) { xml_with_syls '<syl wordpos="i">A</syl>', '<syl wordpos="t">men</syl>' }
    it { expect(subject.lyrics).to eq 'Amen' }
  end

  describe 'two monosyllaba, wordpos not set' do
    let(:xml) { xml_with_syls '<syl>La</syl>', '<syl>La</syl>' }
    it { expect(subject.lyrics).to eq 'La La' }
  end

  describe 'two monosyllaba, wordpos=s' do
    let(:xml) { xml_with_syls '<syl wordpos="s">La</syl>', '<syl wordpos="s">La</syl>' }
    it { expect(subject.lyrics).to eq 'La La' }
  end
end
