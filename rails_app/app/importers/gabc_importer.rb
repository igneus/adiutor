# Pieces of import implementation shared by all importers
# of gabc-based corpora
module GabcImporter
  def extract_stats(chant, gabc_score)
    score_with_stats = GabcScoreStats.new gabc_score
    %i[syllable_count word_count melody_section_count].each do |property|
      chant.public_send "#{property}=", score_with_stats.public_send(property)
    end
  end
end
