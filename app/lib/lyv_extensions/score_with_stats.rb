module LyvExtensions
  # Decorates a Lyv::LilypondScore, extends it with summary stats.
  class ScoreWithStats < SimpleDelegator
    def syllable_count
      __getobj__
        .lyrics_raw
        .split
        .reject {|i| i == '--' }
        .count
    end

    def word_count
      __getobj__
        .lyrics_readable
        .strip
        .split
        .reject {|i| i == '*' }
        .count
    end

    def melody_section_count
      __getobj__
        .music
        .sub(/\\bar\w+\s*}\s*\Z/, '')
        .split(/\\bar\w+/)
        .count
    end
  end
end
