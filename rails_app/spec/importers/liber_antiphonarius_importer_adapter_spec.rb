# coding: utf-8
describe LiberAntiphonariusImporter::Adapter do
  let(:subject) { described_class.new(score, source_code, book) }

  let(:score) { MyGabcParser.call source_code }
  let(:source_code) { "%%\n" }
  let(:book) { double() }

  describe '#lyrics' do
    describe 'initial normalization' do
      let(:source_code) { "%%\n (c4) AL(h)le(h)lú(h)ia(h) (::)" }

      it 'keeps a single capital letter' do
        expect(subject.lyrics).to eq 'Allelúia'
      end
    end
  end
end
