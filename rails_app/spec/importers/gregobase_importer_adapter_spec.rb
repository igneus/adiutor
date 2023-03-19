describe GregobaseImporter::Adapter do
  let(:subject) { described_class.new(gregobase_chant_source, score, music_book, source_code) }

  let(:gregobase_chant_source) { double(chant: double(), source: double()) }
  let(:score) { double(GabcScore) }
  let(:music_book) { MusicBook.new }
  let(:source_code) { '' }

  describe '#lyrics' do
    describe '<alt></alt>' do
      let(:source_code) { "%%\n(f3)A<alt>Omnes genua flectunt</alt>(h/hf/ge)ve,(e.)" }
      let(:score) { MyGabcParser.call source_code }

      it 'ignores it' do
        expect(subject.lyrics).to eq 'Ave,'
      end
    end
  end
end
