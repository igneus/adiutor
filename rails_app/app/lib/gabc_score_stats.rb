# Decorates a GabcScore, extends it with summary stats.
class GabcScoreStats < SimpleDelegator
  def syllable_count
    lyrics.flatten.size
  end

  def word_count
    lyrics.size
  end

  def melody_section_count
  end

  private

  def lyrics
    music.lyric_syllables.reject {|i| i == ['*'] }
  end
end
