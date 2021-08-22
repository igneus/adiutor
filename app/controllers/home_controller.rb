class HomeController < ApplicationController
  def index
    @chants_count = Chant.count
  end
end
