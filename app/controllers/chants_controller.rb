class ChantsController < ApplicationController
  def index
    @chants = Chant.all
  end

  def show
    @chant = Chant.find params[:id]
    @properties = @chant.attributes.except(*%w(id lilypond_code header))
  end
end
