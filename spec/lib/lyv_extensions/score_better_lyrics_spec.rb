describe LyvExtensions::ScoreBetterLyrics do
  describe '#lyrics_readable' do
    [
      ['regular', 'a -- men', 'amen'],
      [
        'daggered, short variant first',
        'one \markup{\Dagger two} three. \markup{\Dagger two} three al -- le -- lu -- ia.',
        'one two three alleluia.'
      ],
      [
        'daggered, long variant first',
        'one \markup{\Dagger two} three al -- le -- lu -- ia. \markup{\Dagger two} three.',
        'one two three alleluia.'
      ],
    ].each do |label, given, expected|
      it label do
        score = Lyv::LilyPondScore.new("\\score { \\addlyrics { #{given} } }")
        decorated = described_class.new score

        expect(decorated.lyrics_readable).to eq expected
      end
    end
  end
end
