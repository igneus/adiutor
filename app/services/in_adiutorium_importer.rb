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

    Lyv::LilyPondMusic.new(path).scores.each do |s|
      puts s
      import_score s, in_project_path, book, cycle
    end
  end

  def import_score(score, in_project_path, book, cycle)
    header = score.header

    set_properties = lambda do |chant|
      chant.book = book
      chant.cycle = cycle
      chant.parent = nil
      chant.lilypond_code = score.text
      chant.lyrics = score.lyrics_readable
      chant.header = header
      chant.textus_approbatus = header['textus_approbatus']&.gsub(/\s+/, ' ')
      %w[quid modus differentia psalmus placet fial].each do |key|
        chant.public_send "#{key}=", header[key]
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
end
