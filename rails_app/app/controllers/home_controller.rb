class HomeController < ApplicationController
  def index
    @chants_count = Chant.count
    @need_fix_total = Chant.to_be_fixed.count

    @chant_to_fix_random =
      Chant
        .to_be_fixed
        .order(Arel.sql('RANDOM()'))
        .limit(1)
        .first
    @chant_to_fix_today = Chant.chant_of_the_day(Time.zone.today)
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
    @invitatory_genre = Genre.find_by!(system_name: 'invitatory')
  end

  def chant_of_the_day
    @date = params[:date].then {|d| d && Date.parse(d) } || Time.zone.today
    @chant = Chant.chant_of_the_day(@date)
  end
end
