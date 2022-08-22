describe LyricsHelper do
  describe '.normalize_initial' do
    [
      ['', ''],
      ['lowercase', 'lowercase'],
      ['Single initial', 'Single initial'],
      ['MULtiple initial', 'Multiple initial'],
    ].each do |given, expected|
      it do
        expect(described_class.normalize_initial(given))
          .to eq expected
      end
    end
  end
end