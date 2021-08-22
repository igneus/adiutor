class ChantsController < ApplicationController
  def index
    @chants = Chant.all
  end

  def show
    @chant = Chant.find params[:id]
    @properties = @chant.attributes.except(*%w(id lilypond_code header))
  end

  def open_in_editor
    raise 'forbidden' unless Rails.env.development?

    chant = Chant.find params[:id]
    EditorOpener.new.(chant)
    flash[:info] = "Chant #{chant.id} opened for editation"

    redirect_back fallback_location: root_path
  end
end
