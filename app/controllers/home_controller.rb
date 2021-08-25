class HomeController < ApplicationController
  def index
    @chants_count = Chant.count
  end

  def overview
    @genres = Chant.genres
    @modes = Chant.modi_and_differentiae
    @books = Book.all
    @cycles = Cycle.all
  end
end
