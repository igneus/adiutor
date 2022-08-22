module LyvExtensions
  # Decorates a Lyv::LilypondScore, extends it with parsing of music.
  # (Only to a limited extent parses the subset of LilyPond syntax actually used
  # in the In adiutorium project.)
  class ScoreNotes < SimpleDelegator
    RELATIVE_RE = /\\relative\s+([a-g][',]*)/
    PITCH_RE = /([a-g]([ei]?s)?)([',]*)/

    def relative_base
      music.match(RELATIVE_RE) {|m| m[1] } ||
        raise('not a score with relative-pitched music')
    end

    def notes
      tokens =
        music
          .sub(RELATIVE_RE, '')
          .scan(/(#{PITCH_RE.source}[()]*)/)
          .collect(&:first)

      # group melisms
      melisma = nil
      tokens
        .collect do |note|
        if note.include? '('
          melisma = [note.sub('(', '')]
          nil
        elsif melisma
          melisma << note
          if note.include?(')')
            melisma.last.sub!(')', '')
            r = melisma
            melisma = nil
            r
          end
        else
          note
        end
      end.compact
    end
  end
end
