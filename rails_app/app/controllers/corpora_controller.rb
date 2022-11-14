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

  def overview
    @corpus = Corpus.find(params[:id])
    with_existing_corpus_chants = lambda do |relation, col|
      ids =
        Chant
          .select(col)
          .distinct
          .where(corpus: @corpus)
      relation.where("id IN (#{ids.to_sql})")
    end

    @genres = with_existing_corpus_chants.(Genre, :genre_id)
    @modes = Chant.where(corpus: @corpus).modi_and_differentiae
    @books = with_existing_corpus_chants.(Book, :book_id)
    @cycles = with_existing_corpus_chants.(Cycle, :cycle_id)
    @seasons = with_existing_corpus_chants.(Season, :season_id)
    @corpuses = [@corpus]
    @hours = with_existing_corpus_chants.(Hour, :hour_id)

    render 'home/overview'
  end
end
