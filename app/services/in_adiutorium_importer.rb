# Imports chants from the directory structure of the "In adiutorium" project sources
class InAdiutoriumImporter
  def call(path)
    Dir["#{path}/**/*.ly"].each {|f| import_file f }
  end

  def import_file(path)
    return if path =~ /(antifonar|cizojazycne|hymny|nechoral|psalmodie|rytmicke|variationes|zalm\d+|kratkeverse)/

    in_project_path =
      path
        .sub(Adiutor::IN_ADIUTORIUM_SOURCES_PATH, '')
        .sub(%r{^/}, '')

    book = book_by_file_path(in_project_path)
    cycle = cycle_by_file_path(in_project_path)
    season = season_by_file_path(in_project_path)

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
        import_score s, in_project_path, book, cycle, season_triduum
      end
    end

    scores.each do |s|
      puts s

      if s.header['id'].blank?
        puts 'score ID missing, skip'
        next
      end

      import_score s, in_project_path, book, cycle, season
    end
  end

  def import_score(score, in_project_path, book, cycle, season)
    header = score.header.transform_values {|v| v == '' ? nil : v }

    score_with_stats = LyvExtensions::ScoreStats.new score

    set_properties = lambda do |chant|
      chant.book = book
      chant.cycle = cycle
      chant.season = season
      chant.parent = nil
      chant.lilypond_code = score.text
      chant.lyrics = score.lyrics_readable
      chant.header = header

      chant.modus = header['modus']&.sub(/\.$/, '')
      chant.textus_approbatus = header['textus_approbatus']&.gsub(/\s+/, ' ')
      %w[quid differentia psalmus placet fial].each do |key|
        chant.public_send "#{key}=", header[key]
      end

      %i[syllable_count word_count melody_section_count].each do |property|
        chant.public_send "#{property}=", score_with_stats.public_send(property)
      end
    end

    Chant
      .find_or_create_by!(chant_id: header['id'], source_file_path: in_project_path, &set_properties)
      .tap(&set_properties)
      .save!
  rescue
    p score
    raise
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
      when %r{^antifony/(tyden|doplnovaci|ferie_kantevgant|invitatoria)}
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
end
