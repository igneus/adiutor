require_relative '../../spec/importers/in_adiutorium_importer_example_data'

# Imports chants from the directory structure of the "In adiutorium" project sources
class InAdiutoriumImporter < BaseImporter
  def call(path)
    detect_genre_examples_check do
      Dir["#{path}/**/*.ly"].each {|f| import_file f, path }
    end
  end

  def import_file(path, dir)
    return if path =~ /(antifonar|cizojazycne|hymny|nechoral|psalmodie|rytmicke|variationes|zalm\d+|kratkeverse)/

    in_project_path =
      path
        .sub(dir, '')
        .sub(%r{^/}, '')

    book = book_by_file_path(in_project_path)
    cycle = cycle_by_file_path(in_project_path)
    season = season_by_file_path(in_project_path)
    language = SourceLanguage.find_by_system_name! 'lilypond'

    scores =
      Lyv::LilyPondMusic
        .new(path)
        .scores
        .collect {|i| LyvExtensions::ScoreBetterLyrics.new i }

    # file due to historical reasons
    # containing chants of two seasons
    if in_project_path == 'velikonoce_velikonocnioktav.ly'
      triduum_scores, scores =
        scores
          .slice_before {|i| p i.header['id'] == 'po-mc-a1' }
          .to_a
      season_triduum = Season.for_cr_season CR::Seasons::TRIDUUM

      triduum_scores.each do |s|
        puts s
        import_score s, in_project_path, book, cycle, season_triduum, corpus, language
      end
    end

    scores.each do |s|
      puts s

      if s.header['id'].blank?
        puts 'score ID missing, skip'
        next
      end

      import_score s, in_project_path, book, cycle, season, corpus, language
    end
  end

  def import_score(score, in_project_path, book, cycle, season, corpus, language)
    header = score.header.transform_values {|v| v == '' ? nil : v }
    chant = Chant.find_or_initialize_by(chant_id: header['id'], source_file_path: in_project_path)

    chant.corpus = corpus
    chant.book = book
    chant.cycle = cycle
    chant.season = season
    chant.source_language = language

    hour, genre = detect_hour_and_genre(header['id'], header['quid'], in_project_path)
    genre = header['adiutor_genre'] if header['adiutor_genre']

    chant.hour = hour && Hour.find_by_system_name!(hour)
    chant.genre = Genre.find_by_system_name!(genre)

    if chant.source_code && chant.source_code != score.text
      delete_image chant
      chant.delete_volpiano!
    end

    update_chant_from_score(chant, score)
    chant.save!
  rescue
    p score
    raise
  end

  def update_chant_from_score(chant, score)
    header = score.header.transform_values {|v| v == '' ? nil : v }

    score_with_stats = LyvExtensions::ScoreStats.new score

    chant.parent = nil
    chant.source_code = score.text
    chant.lyrics =
      score
        .lyrics_readable
        .yield_self {|l| expand_responsory_variables(l) }
        .yield_self {|l| /^(antiphon|invitatory)/ =~ chant.genre.system_name ? l.gsub(/\s*\*\s*/, ' ') : l }
        .strip
    chant.header = header_json header

    chant.modus = header['modus']&.sub(/\.$/, '')
    chant.differentia = header['differentia']&.downcase
    chant.textus_approbatus = header['textus_approbatus']&.gsub(/\s+/, ' ')
    chant.lyrics_normalized = LyricsNormalizer.new.normalize_czech(
      (chant.textus_approbatus ||
       expand_responsory_variables(
         score
           .lyrics_readable
           .sub('\Verse', ' V. ')
           .yield_self {|s| s.scan('\Response').size > 1 ? s[0...s.rindex('\Response')] : s } # cut responsories after the verse (but only those where R2 is repeated)
       ))
        .sub(' V. ', ' | ')
    )
    chant.alleluia_optional = !!(score.music =~ /\\rubr(VelikAleluja|MimoPust)/)
    %w[quid psalmus placet fial].each do |key|
      chant.public_send "#{key}=", header[key]
    end

    fial = header['fial']&.yield_self {|f| FIAL.parse(f) }
    chant.simple_copy = !!fial&.additional&.empty?
    chant.copy = !!fial&.additional&.yield_self do |a|
      a.size == 1 && %w(+aleluja -aleluja).include?(a.keys[0])
    end

    %i[syllable_count word_count melody_section_count].each do |property|
      chant.public_send "#{property}=", score_with_stats.public_send(property)
    end
  end

  def expand_responsory_variables(lyrics)
    lyrics
      .gsub(/\s*\\(Verse|Response|textRespDoxologie)\s*/, ' ')
      .gsub('\textRespAleluja', 'Aleluja, aleluja.')
  end

  def detect_hour_and_genre(id, quid, path)
    hour = detect_hour(id, path)

    [hour, detect_genre(id, quid, path, hour)]
  end

  def detect_genre(id, quid, path, hour_name)
    @detect_genre_examples&.delete [id, quid, path]

    if id =~ /invit/ || path =~ /invitatoria/
      :'invitatory'
    elsif quid =~ /k (Benedictus|Magnificat)/ || id == 'sim' || path =~ /mezidobi_nedele/ || %w(aben amag).include?(id)
      :'antiphon_gospel'
    elsif quid =~ /resp/
      if %w(pust_triduum.ly velikonoce_velikonocnioktav.ly).include? path
        :antiphon
      elsif hour_name == :readings
        :'responsory_nocturnal'
      else
        :'responsory_short'
      end
    elsif path =~ /^marianske/
      :'antiphon_standalone'
    elsif path =~ /^(kompletar|antifony\/(tyden|ferie|doplnovaci))/
      :'antiphon_psalter'
    elsif quid =~ /ant(\.|ifona)/
      :'antiphon'
    else
      :'varia'
    end
  end

  def detect_hour(chant_id, path)
    hour =
      case path
      when /^kompletar/, /^marianske_antifony/
        :compline
      when /knzkantikum/
        :vespers
      else
        nil
      end

    hour ||=
      case chant_id
      when /(mc|cte)/
        :'readings'
      when /(^|-)rch/, /ben\d?$/, /predvanocni-zlm-/
        :'lauds'
      when /(^|-)up/, /tercie/, /sexta/, /nona/, 'prima', 'dopo', 'po', 'odpo'
        :'daytime'
      when /(^|-)\d?ne/, /mag(\d|i+)?$/, /^predvanocni-\d+-o$/
        :'vespers'
      when /komplet/
        :'compline'
      else
        nil
      end

    return nil if path =~ /zakladni_napevy/

    hour
  end

  private

  def book_by_file_path(in_project_path)
    book_name =
      case in_project_path
      when /^reholni/
        in_project_path.split('/')[1].downcase
      when /^paraliturgicke/
        'other'
      when 'velikonoce_vigilie.ly'
        'olm'
      else
        'dmc'
      end

    Book.find_by_system_name! book_name
  end

  def cycle_by_file_path(in_project_path)
    cycle_name =
      case in_project_path
      when %r{^antifony/(tyden|doplnovaci|ferie_kantevgant|invitatoria)}, 'responsoria.ly'
        'psalter'
      when %r{^(sanktoral|reholni)/}
        'sanctorale'
      when 'zakladni_napevy.ly', 'marianske_antifony.ly', %r{^invitatoria/}
        'ordinarium'
      else
        'temporale'
      end

    Cycle.find_by_system_name! cycle_name
  end

  def season_by_file_path(in_project_path)
    season =
      case File.basename(in_project_path)
      when /^advent/
        CR::Seasons::ADVENT
      when /^vanoce/
        CR::Seasons::CHRISTMAS
      when /^pust_triduum/
        CR::Seasons::TRIDUUM
      when /^pust/
        CR::Seasons::LENT
      when /^velikonoce/
        CR::Seasons::EASTER
      when /^mezidobi/
        CR::Seasons::ORDINARY
      else
        nil
      end

    season && Season.for_cr_season(season)
  end

  def delete_image(chant)
    puts "deleting image of #{chant.fial_of_self}"
    path = LilypondImageGenerator.image_path chant
    File.delete path if File.exist? path
  end

  def header_json(score_header)
    score_header
      .dup
      .tap do |h|
      fial_key = 'fial'
      # FIAL denormalized to JSON object of components
      # to allow exact SQL querying by FIAL contents
      if h[fial_key]
        h[fial_key] = FIAL.parse(h[fial_key]).as_json
      end
    end
  end

  # Checks if code in the block meets all examples of #detect_genre tests
  # in the real world data, prints results.
  def detect_genre_examples_check
    examples = @detect_genre_examples = Set.new(
      InAdiutoriumImporterExampleData.detect_genre_argument_sets
    )

    yield

    unless examples.empty?
      STDERR.puts "#{examples.size} #detect_genre test examples not encountered in real world data:"
      examples.to_a.each do |a|
        STDERR.puts a.inspect
      end
    end

    @detect_genre_examples = nil
  end
end
