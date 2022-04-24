class ChantsController < ApplicationController
  def index
    @chants = Chant.where(filter_params).joins(:source_language)
    if params[:lyrics]
      @chants = @chants.where("lyrics ILIKE ?", "%#{params[:lyrics]}%")
    end
    %i[volpiano pitch_series interval_series].each do |attr|
      if params[attr]
        @chants = @chants.where("#{attr} LIKE ?", "%#{params[attr]}%")
      end
    end
    if params[:neume]
      @chants = @chants.where("volpiano LIKE ?", "%-#{params[:neume]}-%")
    end

    @display_music = @chants.count < 500
  end

  def show
    @chant = Chant.find params[:id]
    @properties = @chant.attributes.except(*%w(id source_code header lyrics textus_approbatus))

    @similar_structure = Chant.similar_by_structure_to(@chant)
    @similar_length = Chant.similar_by_lyrics_length_to(@chant)
  end

  def open_in_editor
    raise 'forbidden' unless Rails.env.development?

    chant = Chant.find params[:id]
    EditorOpener.new.(chant, params[:line])
    flash[:info] = "Chant #{chant.id} opened for editation"

    redirect_back fallback_location: root_path
  end

  def compare
    @chant_a = Chant.find params[:id]
    @chant_b = Chant.find params[:other_id]

    @relation =
      @chant_b.parent == @chant_a &&
        FIAL.parse(@chant_b.fial).additional
  end

  private

  def filter_params
    params.permit(
      :quid,
      :modus,
      :differentia,
      :psalmus,
      :book_id,
      :corpus_id,
      :cycle_id,
      :season_id,
      :genre_id,
      :hour_id,
      :source_language_id,
      :word_count,
      :melody_section_count
    )
  end
end
