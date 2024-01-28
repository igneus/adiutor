# coding: utf-8
describe GregobaseImporter::Adapter do
  let(:subject) { described_class.new(const_attrs, gregobase_chant_source, score) }

  let(:gregobase_chant) { double() }
  let(:gregobase_source) { double() }
  let(:gregobase_chant_source) { double(chant: gregobase_chant, source: gregobase_source) }
  let(:score) { MyGabcParser.call source_code }
  let(:music_book) { MusicBook.new }
  let(:source_code) { "%%\n" }
  let(:const_attrs) { double(music_book: music_book, source_code: source_code) }

  include_examples 'attributes passed from the outside', %i[music_book source_code] do
    let(:other_constructor_args) { [gregobase_chant_source, score] }
  end

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

    describe 'antiphon with a tag' do
      let(:gregobase_chant) { double('office-part': 'an', tags: [double(tag: 'Ad invitatorium')]) }

      it 'is an invitatory' do
        expect(subject.genre_system_name).to eq 'invitatory'
      end
    end
  end

  describe 'detecting hour' do
    describe 'by tags' do
      [
        [[], nil],
        [['unknown tag'], nil],

        [['Ad I Vesperas'], 'vespers'],
        [['Ad II Vesperas'], 'vespers'],
        [['1/1 ad Off. lect. A1'], 'readings'],
        [['Ad Laudes'], 'lauds'],
        [['Ad Primam'], 'daytime'],
        [['Ad Tertiam'], 'daytime'],
        [['Ad Sextam'], 'daytime'],
        [['Ad Nonam'], 'daytime'],
        [['Ad Vigilias'], 'readings'],
        [['Ad Completorium'], 'compline'],

        [['irrelevant tag', 'Ad II Vesperas'], 'vespers'],
      ].each do |tags, expected|
        describe tags.inspect do
          let(:gregobase_chant) { double(tags: tags.collect {|t| double(tag: t) }) }

          it "detects #{expected}" do
            expect(subject.hour_system_name).to eq expected
          end
        end
      end
    end
  end

  describe 'detecting season' do
    describe 'by tags' do
      [
        [[], nil],
        [['unknown tag'], nil],

        [['Dominica 1 Adventus'], :advent],
        [['In Nativitate Domini'], :christmas],
        [['Ad vigilias in T. Quadragesimæ'], :lent],
        [['Hebdomada Sancta'], :lent],
        [['Dominica Paschae'], :easter],
        # [[''], ''],
      ].each do |tags, expected|
        describe tags.inspect do
          let(:gregobase_chant) { double(tags: tags.collect {|t| double(tag: t) }) }

          it "detects #{expected}" do
            expect(subject.season_system_name).to eq expected
          end
        end
      end
    end
  end
end
