module LyvExtensions
  class Absolutizer
    NOTES = %w(c d e f g a b)

    # Takes a single absolute pitch as reference point and a series of relative
    # LilyPond notes, translates them to absolute ones.
    def absolutize(absolute_pitch, relative_notes)
      relative_notes.collect do |i|
        absolute_pitch = absolutize_note(absolute_pitch, i)
      end
    end

    private

    def absolutize_note(absolute_pitch, relative_note)
      interval = NOTES.index(relative_note[0]) - NOTES.index(absolute_pitch[0])
      if interval >= 4
        lower_octave(relative_note)
      else
        relative_note
      end
    end

    def lower_octave(note)
      if note.include? "'"
        note.sub "'", ''
      else
        note.sub(ScoreNotes::PITCH_RE) {|m| m + ',' }
      end
    end
  end
end
