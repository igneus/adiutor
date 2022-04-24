class HomeController < ApplicationController
  def index
    @chants_count = Chant.count
  end

  def overview
    @genres = Genre.all
    @modes = Chant.modi_and_differentiae
    @books = Book.all
    @cycles = Cycle.all
    @seasons = Season.all
    @corpuses = Corpus.all
    @hours = Hour.all
  end

  def required_psalm_tunes
    @tunes = Chant.required_psalm_tunes
  end
end
