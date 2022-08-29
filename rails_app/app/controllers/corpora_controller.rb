class CorporaController < ApplicationController
  def index
    @corpora = Corpus.all
  end

  def differentiae
    @corpus = Corpus.find(params[:id])
    @differentiae = @corpus.differentiae
  end
end
