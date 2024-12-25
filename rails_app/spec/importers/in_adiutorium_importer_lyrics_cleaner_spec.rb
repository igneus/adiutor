describe InAdiutoriumImporter::LyricsCleaner do
  [
    ['already clean', 'already clean'],
    ['Saint \markup\Nomen rules', 'Saint N. rules'],
    ['pre \markup{MARKED UP} post', 'pre MARKED UP post'],
    ['pre \markup\bold{MARKED UP} post', 'pre MARKED UP post'],
    ['pre \markup\italic{MARKED UP} post', 'pre MARKED UP post'],
    ['pre \markup\underline{MARKED UP} post', 'pre MARKED UP post'],
    ['pre "QUOTED" post', 'pre QUOTED post'],
    ['pre \skip 1 post', 'pre post'],
  ].each do |(given, expected)|
    it given do
      expect(described_class.(given))
        .to eq expected
    end
  end
end
