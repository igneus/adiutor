module LyvExtensions
  # Decorates a Lyv::LilypondScore, modifies it to better understand
  # lyric constructs used in the In adiutorium chant corpus.
  class ScoreBetterLyrics < SimpleDelegator
    def lyrics_readable
      r =
        lyrics_raw
          .gsub(' -- ', '')
          .gsub('_', ' ')
          .gsub(/\\markup\{(.*?)\}/, '\1')
          .gsub(/\s+/, ' ')
          .strip

      if r.include? '\Dagger'
        # alternative endings
        r
          .split(/\s*\\Dagger\s*/)
          .then { |s| s[0] + ' ' + s[1..-1].max_by(&:size) }
      else
        r
      end
    end
  end
end
