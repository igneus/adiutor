# coding: utf-8
# Transformations specific for gabc lyrics,
# (at least potentially) useful across imported corpora.
module GabcLyricsHelper
  extend self

  # replace selected special characters with their plaintext equivalents
  def decode_special_characters(str)
    str
      .gsub(%r{<sp>([ao]e)</sp>}) { Regexp.last_match[1] }
      .gsub(%r{<sp>'([ao])e</sp>}) { Regexp.last_match[1] + 'é' }
      .gsub("<sp>'æ</sp>", 'aé')
      .gsub("<sp>'œ</sp>", 'oé')
  end

  # remove text which is not part of the lyrics
  def remove_attached_text(str)
    str
      .gsub(%r{<alt>.*?</alt>}, '')
  end
end
