describe GregobaseImporter::Adapter do
  let(:subject) { described_class.new(gregobase_chant_source, score, music_book, source_code) }

  let(:gregobase_chant_source) { double(chant: double(), source: double()) }
  let(:score) { MyGabcParser.call source_code }
  let(:music_book) { MusicBook.new }
  let(:source_code) { '' }

  describe '<alt></alt>' do
    let(:source_code) { "%%\n(f3)A<alt>Omnes genua flectunt</alt>(h/hf/ge)ve,(e.)" }

    it { is_expected.to have_attributes lyrics: 'Ave,' }
    it { is_expected.to have_attributes lyrics_normalized: 'ave' }
  end
end
