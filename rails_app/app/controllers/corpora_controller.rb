class CorporaController < ApplicationController
  def differentiae
    @corpus = Corpus.find(params[:id])
    @differentiae = @corpus.differentiae
  end
end
