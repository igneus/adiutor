module LyvExtensions
  # Decorates a Lyv::LilypondScore, extends it with summary stats.
  class ScoreStats < SimpleDelegator
    def syllable_count
      lyrics_raw
        .split
        .reject {|i| i == '--' }
        .count
    end

    def word_count
      lyrics_readable
        .strip
        .split
        .reject {|i| i == '*' }
        .count
    end

    def melody_section_count
      music
        .sub(/\\bar\w+\s*}\s*\Z/, '')
        .split(/\\bar\w+/)
        .reject {|i| i.include? '\markup\rubrVelikAleluja' }
        .count
    end
  end
end
