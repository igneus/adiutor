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

  describe '.remove_euouae' do
    [
      ['', ''],
      ['no euouae', 'no euouae'],
      ['Amen. E u o u a e.', 'Amen.'],
      ['Amen. E U O U A E.', 'Amen.'],
      ['Amen. E u o u a e', 'Amen.'],
    ].each do |given, expected|
      it do
        expect(described_class.remove_euouae(given))
          .to eq expected
      end
    end
  end
end
