describe DivinumOfficium::Formulary do
  let(:subject) { described_class.new source }

  describe '#items' do
    describe 'empty file' do
      let(:source) { '' }

      it 'is empty' do
        expect(subject.items).to eq []
      end
    end

    describe 'one item' do
      let(:source) { "[Title]\nContents" }

      it 'is available' do
        expect(subject.items.size).to be 1

        i = subject.items[0]
        expect(i.title).to eq 'Title'
        expect(i.text).to eq 'Contents'
      end
    end

    describe 'two items' do
      let(:source) { "[Title]\nContents\n\n[Another]\nMore contents" }

      it 'is available' do
        expect(subject.items.size).to be 2

        i = subject.items[0]
        expect(i.title).to eq 'Title'
        expect(i.text).to eq 'Contents'

        i = subject.items[1]
        expect(i.title).to eq 'Another'
        expect(i.text).to eq 'More contents'
      end
    end

    describe 'attached numbers' do
      [
        ';;93',
        ';;269;270;271',
      ].each do |numbers|
        describe numbers do
          let(:source) { "[Title]\nContents" + numbers }
          it 'ignores them' do
            expect(subject.items.size).to be 1

            i = subject.items[0]
            expect(i.title).to eq 'Title'
            expect(i.text).to eq 'Contents'
          end
        end
      end
    end
  end

  describe '#antiphons' do
    describe 'non-antiphon' do
      let(:source) { "[Lectio Prima]\nlesson content" }

      it 'is not found' do
        expect(subject.antiphons).to be_empty
      end
    end

    describe 'antiphon' do
      let(:source) { "[Ant 2]\nantiphon content" }

      it 'is found' do
        expect(subject.antiphons).not_to be_empty
      end
    end
  end
end
