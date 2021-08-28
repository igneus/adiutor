describe LyvExtensions::ScoreNotes do
  describe '#relative_base' do
    [
      '',
      ' ',
      '{ a }',
    ].each do |given|
      it given do
        score = double(Lyv::LilyPondScore, music: given)
        decorated = described_class.new score

        expect { decorated.relative_base }
          .to raise_exception(RuntimeError, /not a score with relative-pitched music/)
      end
    end

    [
      ['\relative c\' {}', "c'"],
      ['\relative c\'\' {}', "c''"],
    ].each do |given, expected|
      it given do
        score = double(Lyv::LilyPondScore, music: given)
        decorated = described_class.new score

        expect(decorated.relative_base).to eq expected
      end
    end
  end

  describe '#notes' do
    [
      ['\relative c\' { a }', ['a']],
      ['{ a }', ['a']],
      ['{ as }', ['as']],
      ['{ aes }', ['aes']],
      ['{ ais }', ['ais']],
      ['\relative c\' { a b c d e f g }', %w(a b c d e f g)],
      ['{ a4 }', ['a']],
      ['{ a4. }', ['a']],
      ["{ a' }", ["a'"]],
      ['{ a, }', ['a,']],
      ['{ a( b) }', [['a', 'b']]],
      ['{ a( c b) }', [['a', 'c', 'b']]],
      ['{ c a( b) }', ['c', ['a', 'b']]],
      ['{ a( b) c }', [['a', 'b'], 'c']],
    ].each do |given, expected|
      it given do
        score = double(Lyv::LilyPondScore, music: given)
        decorated = described_class.new score

        expect(decorated.notes).to eq expected
      end
    end
  end
end
