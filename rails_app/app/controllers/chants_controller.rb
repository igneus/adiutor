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

    filter = ChantsFilter.new
    @filter_form = ChantsFilterForm.new filter
    @filter_form.validate(
      params
        .to_unsafe_h # the form takes care of data safety
        .yield_self {|x| x.merge(x[:chants_filter] || {}) } # support both scoped and unscoped parameters
      )
    @filter_form.sync

    @chants =
      Chant
        .filtered(filter)
        .page(params[:page] || 1)

    @show_placet = filter.quality_notice
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

  def source
    @chant = Chant.find params[:id]

    # TODO: set reasonable content type
    render body: @chant.source_code
  end
end
