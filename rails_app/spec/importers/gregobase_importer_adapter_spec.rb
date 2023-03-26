# coding: utf-8
describe GregobaseImporter::Adapter do
  let(:subject) { described_class.new(gregobase_chant_source, score, music_book, source_code) }

  let(:gregobase_chant) { double() }
  let(:gregobase_source) { double() }
  let(:gregobase_chant_source) { double(chant: gregobase_chant, source: gregobase_source) }
  let(:score) { MyGabcParser.call source_code }
  let(:music_book) { MusicBook.new }
  let(:source_code) { "%%\n" }

  describe '<alt></alt>' do
    let(:source_code) { "%%\n(f3)A<alt>Omnes genua flectunt</alt>(h/hf/ge)ve,(e.)" }

    it { is_expected.to have_attributes lyrics: 'Ave,' }
    it { is_expected.to have_attributes lyrics_normalized: 'ave' }
  end

  # GregoBase doesn't recognize invitatories as a separate genre
  describe 'detecting invitatories' do
    describe 'Liber hymnarius' do
      let(:gregobase_chant) { double('office-part': 'an') }
      let(:music_book) { MusicBook.new title: 'Liber hymnarius' }

      it 'any antiphon is an invitatory' do
        expect(subject.genre_system_name).to eq 'invitatory'
      end
    end

    describe 'antiphon with lyrics ending with a Venite incipit' do
      [
        'Ve(h)ní(h)te.(h)',
        'Ve(h)ní(h)te,(h)',
        'Ve(h)ní(h)te(h)',
        'Ve(h)ni(h)te(h)',
      ].each do |psalm_incipit|
        describe psalm_incipit do
          let(:gregobase_chant) { double('office-part': 'an') }
          let(:source_code) do
            "%%\n (c4) An(h)ti(h)phon(h) ly(h)rics.(h) (::) " +
              psalm_incipit + ' (::)'
          end

          it 'is an invitatory' do
            expect(subject.genre_system_name).to eq 'invitatory'
          end
        end
      end
    end
  end
end
