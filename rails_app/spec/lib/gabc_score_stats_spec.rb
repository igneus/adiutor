describe GabcScoreStats do
  let(:parser) { GabcParser.new }

  describe '#word_count' do
    [
      ['', 0],
      [' ', 0],
      ['  ', 0],
      ['%comment', 0],
      ['a(i)', 1],
      ['a(i j)', 1],
      ['a(i)a(i)', 1],
      ['a(i) a(i)', 2],
      ['a(i) (,) a(i) (;) a(i) (:) a(i) (::)', 4, 'differentiae do not count'],
      ['a(i) *() a(i)', 2, 'syllable with empty music does not count'],
      ['a(i) *(,) a(i)', 2, 'differentia with "lyrics" does not count'],
    ].each do |given, expected, label|
      it(label || "word count of '#{given}'") do
        score = parser.parse("%%\n" + given).create_score
        decorated = described_class.new score

        expect(decorated.word_count).to eq expected
      end
    end
  end

  describe '#syllable_count' do
    [
      ['', 0],
      [' ', 0],
      ['a(i)', 1],
      ['a(i)a(i)', 2],
      ['a(i) a(i)', 2],
      ['a(i) (,) a(i) (;) a(i) (:) a(i) (::)', 4, 'differentiae do not count'],
      ['a(i) *() a(i)', 2, 'syllable with empty music does not count'],
      ['a(i) *(,) a(i)', 2, 'differentia with "lyrics" does not count'],
    ].each do |given, expected, label|
      it(label || "word count of '#{given}'") do
        score = parser.parse("%%\n" + given).create_score
        decorated = described_class.new score

        expect(decorated.syllable_count).to eq expected
      end
    end
  end
end
