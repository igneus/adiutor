describe LyvExtensions::ScoreStats do
  describe '#word_count' do
    [
      ['', 0],
      [' ', 0],
      ['  ', 0],
      ['a', 1],
      [' a ', 1],
      ['a b', 2],
      ["a\nb", 2],
      ["incipit * after asterisk", 3],
    ].each do |given, expected|
      it "word count of '#{given}'" do
        score = double(Lyv::LilyPondScore, lyrics_readable: given)
        decorated = described_class.new score

        expect(decorated.word_count).to eq expected
      end
    end
  end

  describe '#syllable_count' do
    [
      ['', 0],
      [' ', 0],
      ['  ', 0],
      ['a', 1],
      [' a ', 1],
      ['ab', 1],
      ['a_b', 1],
      ['a b', 2],
      ["a\nb", 2],
      ["a -- b", 2],
      ["a -- \nb", 2],
      ["a -- b -- c", 3],
    ].each do |given, expected|
      it "syllable count of '#{given}'" do
        score = double(Lyv::LilyPondScore, lyrics_raw: given)
        decorated = described_class.new score

        expect(decorated.syllable_count).to eq expected
      end
    end
  end

  describe '#melody_section_count' do
    [
      ['\relative {}', 1],
      ['\relative { a }', 1],
      ['\relative { a a a }', 1],
      ['\relative { a a a \barFinalis }', 1],
      ['\relative { a a \barFinalis a }', 2],
      ['\relative { a a \barMin a }', 2],
      ['\relative { a a \barMaior a }', 2],
    ].each do |given, expected|
      it "melody section count of '#{given}'" do
        score = double(Lyv::LilyPondScore, music: given)
        decorated = described_class.new score

        expect(decorated.melody_section_count).to eq expected
      end
    end
  end
end
