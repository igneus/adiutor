# coding: utf-8
RSpec.describe LyricsNormalizer do
  SHARED_EXAMPLES = [
    ['a', 'a'],
    ['A', 'a', 'downcases letters'],

    ['a,.:!;? a', 'a a', 'removes interpunction'],
    ['a* a', 'a a', 'removes asterisk'],
    ['a * a', 'a a', 'removes separate asterisk'],
    ['a *', 'a', 'correctly removes trailing asterisk'],

    ['|', '|', 'does no harm to the pipe'],

    ['', nil, 'returns nil instead of empty string'],

    [" a \n \t ", 'a', 'strips leading/trailing whitespace'],
    ["a a\na", 'a a a', 'normalizes all whitespace to single spaces'],
  ]

  describe '#normalize_czech' do
    (SHARED_EXAMPLES +
     [
       ['Ž', 'ž', 'downcases non-ASCII letters'],
     ]).each do |given, expected, label|
      it(label || given) do
        expect(subject.normalize_czech(given)).to eq expected
      end
    end
  end

  describe '#normalize_latin' do
    (SHARED_EXAMPLES +
     [
       ['jJ', 'ii', 'converts J'],
       ['áéíóúý', 'aeiouy', 'strips diacritics'],
       ['Ææ Ǽǽ Œœ', 'aeae aeae oeoe', 'normalizes digraphs'],
     ]).each do |given, expected, label|
      it(label || given) do
        expect(subject.normalize_latin(given)).to eq expected
      end
    end
  end
end
