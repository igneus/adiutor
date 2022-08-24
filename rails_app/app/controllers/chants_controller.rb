class ChantsController < ApplicationController
  def index
    @genres = Genre.all
    #@modes = Chant.modi_and_differentiae
    @books = Book.all
    @cycles = Cycle.all
    @seasons = Season.all
    @corpora = Corpus.all
    @hours = Hour.all
    @source_languages = SourceLanguage.all
    @music_search_types = [
      ['literal', 'Literal'],
      ['pitches', 'Pitch series'],
      ['intervals', 'Interval series'],
    ]

    @chants =
      Chant
        .where(filter_params)
        .includes(:mismatches, :source_language)
    if params[:lyrics]
      like = params[:case_sensitive] ? 'LIKE' : 'ILIKE'
      @chants = @chants.where("lyrics #{like} ?", "%#{params[:lyrics]}%")
    end
    volpiano = params[:volpiano]
    if volpiano
      attr = :volpiano
      value = volpiano
      case params[:music_search_type]
      when 'pitches'
        attr = :pitch_series
        value = VolpianoDerivates.pitch_series volpiano
      when 'intervals'
        attr = :interval_series
        value = VolpianoDerivates.snippet_to_interval_series volpiano
      end
      @chants = @chants.where("#{attr} LIKE ?", "%#{value}%")
    end
    if params[:neume]
      @chants = @chants.where("volpiano LIKE ?", "%-#{params[:neume]}-%")
    end

    @chants = @chants.page(params[:page] || 1)
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
    result = EditorOpener.new.(chant, params[:line])

    case result
    when true
      flash[:info] = "Chant #{chant.id} opened for editation"
    when :timeout
      flash[:error] = "Failed to call editor in time. You must have a Frescobaldi process running in order to use this functionality."
    else
      raise "Unexpected return value #{result.inspect}"
    end

    redirect_back fallback_location: root_path
  end

  def compare
    @chant_a = Chant.find params[:id]
    @chant_b = Chant.find params[:other_id]

    @relation =
      @chant_b.parent == @chant_a &&
        FIAL.parse(@chant_b.fial).additional
  end

  def fial
    fial = params[:fial]
    parsed = FIAL.parse fial
    chant = Chant.find_by(source_file_path: parsed.path, chant_id: parsed.id)

    if chant
      redirect_to chant_path(chant)
      return
    end

    raise "FIAL #{fial.inspect} not found"
  end

  private

  def filter_params
    params.permit(
      :quid,
      :modus,
      :differentia,
      :psalmus,
      :word_count,
      :melody_section_count,
      genre_id: [],
      book_id: [],
      corpus_id: [],
      cycle_id: [],
      season_id: [],
      hour_id: [],
      source_language_id: []
    )
  end
end
