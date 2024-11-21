describe NocturnaleImporter::Adapter do
  subject { described_class.new(source_code, score, path) }

  let(:source_code) { "%%\n" }
  let(:score) { MyGabcParser.call source_code }
  let(:path) { 'file.gabc' }

  describe 'detecting genre' do
    [
      ['1225N1A1.gabc', 'antiphon'],
      ['F1N1A1.gabc', 'antiphon_psalter'],
    ].each do |path, genre|
      it genre do
        expect(
          described_class.new(source_code, score, path)
            .genre_system_name
        ).to eq genre
      end
    end
  end

  describe 'detecting modus and differentia' do
    [
      ['mode:;', nil, nil],
      ['mode:4;', 'IV', nil],
      ['mode:4e;', 'IV', 'e'],
    ].each do |(snip, expected_modus, expected_differentia)|
      it snip do
        source = "#{snip}\n%%\n"
        score = MyGabcParser.call source
        adapter = described_class.new(source, score, path)

        expect(adapter.modus).to eq expected_modus
        expect(adapter.differentia).to eq expected_differentia
      end
    end
  end
end
