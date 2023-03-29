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
      ['neume', 'Neume'],
    ]
    @like_types = [
      ['contain', 'Contains'],
      ['beginning', 'Begins with'],
      ['end', 'Ends with'],
    ]
    @source_files = Corpus.find_by_system_name!('in_adiutorium').chants.select(:source_file_path).distinct.order(:source_file_path)

    @chants =
      Chant
        .where(filter_params)
        .includes(:mismatches, :source_language, :corpus)
    if params[:lyrics].present?
      lyrics_like_str = like_search_string(params[:lyrics], params[:lyrics_like_type])
      like = params[:case_sensitive] ? 'LIKE' : 'ILIKE'
      @chants = @chants.where("lyrics #{like} ? OR textus_approbatus #{like} ?", lyrics_like_str, lyrics_like_str)
    end
    volpiano = params[:volpiano]
    if volpiano.present?
      attr = :volpiano
      value = volpiano
      case params[:music_search_type]
      when 'pitches'
        attr = :pitch_series
        value = VolpianoDerivates.pitch_series volpiano
      when 'intervals'
        attr = :interval_series
        value = VolpianoDerivates.snippet_interval_series volpiano
      when 'neume'
        value = "-#{value}-"
      end
      @chants = @chants.where("#{attr} LIKE ?", like_search_string(value, params[:volpiano_like_type]))
    end
    if params[:quality_notice]
      @chants = @chants.to_be_fixed
    end
    if params[:favourite]
      @chants = @chants.favourite
    end
    if params[:mismatch]
      @chants = @chants.joins(:mismatches)
    end
    if params[:lyrics_edited]
      @chants = @chants.where('textus_approbatus IS NOT NULL')
    end
    if params[:fons_externus]
      @chants = @chants.have_fons_externus
    end
    if params[:ids]
      @chants = @chants.where(id: params[:ids].split(',').collect(&:to_i))
    end
    if params[:source_file_path].present?
      @chants =
        @chants
          .where(source_file_path: params[:source_file_path])
          .order(:source_file_position)
    end

    @chants = @chants.page(params[:page] || 1)
  end

  def atypical_responsories
    @corpus = Corpus.find_by_system_name('in_adiutorium')
    @genre = Genre.find_by_system_name('responsory_short')

    @chants =
      Chant
        .where(
          corpus: @corpus,
          genre: @genre
        )
        .where.not(modus: nil)
        .where.not("modus = 'VI' AND (source_code LIKE ? OR source_code LIKE ? OR source_code LIKE ?)", '%respVIdoxologie%', '%respVIalelujaDoxologie%', '%doxologieResponsoriumVI%')
        .order(:source_file_path, :id)
        .page(params[:page] || 1)

    @count_total = Chant.where(corpus: @corpus, genre: @genre).count
    @count_atyp = @chants.total_count
  end

  def clusters
    @chants =
      Corpus
        .find_by_system_name!('in_adiutorium')
        .chants
        .top_parents
        .order(children_tree_size: :desc, lyrics: :asc)
        .page(params[:page] || 1)
  end

  def show
    @chant = Chant.find params[:id]
    @properties = @chant.attributes.except(*%w(id source_code header lyrics textus_approbatus))

    @similar_structure = Chant.similar_by_structure_to(@chant)
    @similar_length = Chant.similar_by_lyrics_length_to(@chant)
  end

  def open_in_editor
    raise 'forbidden' unless Rails.env.development?
    authenticate_user!
    raise 'URL of the external fial opener service not specified' unless Adiutor::EDIT_FIAL_URL

    chant = Chant.find params[:id]

    query = {
      apiKey: Adiutor::EDIT_FIAL_SECRET,
      fial:
        chant.fial_of_self,
      line: params[:line],
      redirectBack: params[:redirect_back] || request.referer || chant_url(chant)
    }
    query[:variationes] = 'true' if params[:variationes] == 'true'

    session[:last_open_in_editor] = query

    target = Adiutor::EDIT_FIAL_URL + '?' + URI.encode_www_form(query)

    redirect_to target
  end

  def open_in_editor_retry
    authenticate_user!
    query = session[:last_open_in_editor]

    if query.nil?
      flash[:error] = 'No previous "open in editor" found.'
      redirect_back fallback_location: root_path
      return
    end

    target = Adiutor::EDIT_FIAL_URL + '?' + URI.encode_www_form(query)

    redirect_to target
  end

  def add_quality_notice
    raise 'forbidden' unless Rails.env.development?
    authenticate_user!

    chant = Chant.find params[:id]
    result = AddQualityNotice.new.(chant)
    if result.error?
      flash[:error] = result.message
    else
      flash[:info] = 'Quality notice added.'
    end

    redirect_back fallback_location: chant_url(chant)
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
      :word_count,
      :melody_section_count,
      :alleluia_optional,
      genre_id: [],
      book_id: [],
      corpus_id: [],
      cycle_id: [],
      season_id: [],
      hour_id: [],
      source_language_id: [],
      music_book_id: [],
      simple_copy: []
    )
  end

  def like_search_string(str, search_type)
    case search_type
    when 'beginning'
      "#{str}%"
    when 'end'
      "%#{str}"
    else
      "%#{str}%"
    end
  end
end
