# Decorates a GabcScore, extends it with summary stats.
class GabcScoreStats < SimpleDelegator
  def syllable_count
    lyrics.flatten.size
  end

  def word_count
    lyrics.size
  end

  def melody_section_count
    sections_enum =
      music
        .words
        .flat_map(&:to_a)
        .slice_after do |syllable|
      syllable.notes.any? {|n| n.is_a? GabcDivisio } &&
        syllable.lyrics !~ /T\.\s*P\./
    end

    sections_enum.to_a.size
  end

  private

  def lyrics
    music.lyric_syllables.reject {|i| i == ['*'] }
  end
end
