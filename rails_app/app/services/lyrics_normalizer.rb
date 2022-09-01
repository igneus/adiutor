# coding: utf-8
# Prepares version of chant lyrics suitable for search disregarding
# differences in minor details.
class LyricsNormalizer
  def normalize_czech(lyrics)
    normalize(lyrics)
      .yield_self {|a| a.empty? ? nil : a }
  end

  def normalize_latin(lyrics)
    normalize(lyrics)
      .gsub('j', 'i')
      .gsub(/[Ǽǽ]/, 'ae') # I18n.transliterate doesn't get accented digraphs right
      .yield_self(&I18n.method(:transliterate))
      .yield_self {|a| a.empty? ? nil : a }
  end

  protected

  def normalize(lyrics)
    lyrics
      .gsub(/[,.:;!?*]+/, '')
      .gsub(/\s+/, ' ')
      .strip
      .downcase
  end
end
