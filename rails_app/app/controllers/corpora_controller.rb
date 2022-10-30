class CorporaController < ApplicationController
  def index
    @corpora = Corpus.all.select(
      '*',
      '(SELECT COUNT(*) FROM chants WHERE corpus_id = corpuses.id) AS total_count',
      '(SELECT COUNT(*) FROM chants WHERE corpus_id = corpuses.id AND volpiano IS NULL) AS volpiano_missing_count'
    )
  end

  def differentiae
    @corpus = Corpus.find(params[:id])
    @differentiae = @corpus.differentiae
  end
end
