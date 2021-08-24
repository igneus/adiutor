class ChantsController < ApplicationController
  def index
    @chants = Chant.where(filter_params)
    @display_music = @chants.count < 500
  end

  def show
    @chant = Chant.find params[:id]
    @properties = @chant.attributes.except(*%w(id lilypond_code header lyrics textus_approbatus))
  end

  def open_in_editor
    raise 'forbidden' unless Rails.env.development?

    chant = Chant.find params[:id]
    EditorOpener.new.(chant, params[:line])
    flash[:info] = "Chant #{chant.id} opened for editation"

    redirect_back fallback_location: root_path
  end

  private

  def filter_params
    params.permit(:quid, :modus, :differentia)
  end
end
