describe LyvExtensions::Absolutizer do
  [
    ['c', [], []],
    ['c', ['c'], ['c']],
    ['c', ['d'], ['d']],
    ['c', ['e'], ['e']],
    ['c', ['f'], ['f']],

    ['c', ['g'], ['g,']],
    ['c', ['a'], ['a,']],
    ['c', ['b'], ['b,']],

    ['c', ["g'"], ["g"]],
    ['c', ["g''"], ["g'"]],
  ].each do |pitch, notes, expected|
    it "#{pitch} #{notes}" do
      expect(subject.absolutize(pitch, notes)).to eq expected
    end
  end
end