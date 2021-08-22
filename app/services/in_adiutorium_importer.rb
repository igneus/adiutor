# Imports chants from the directory structure of the "In adiutorium" project sources
class InAdiutoriumImporter
  def call(path)
    Dir["#{path}/**/*.ly"].each {|f| import_file f }
  end

  def import_file(path)
    return if path =~ /(antifonar|cizojazycne|nechoral|rytmicke)/

    Lyv::LilyPondMusic.new(path).scores.each do |s|
      puts s
      import_score s
    end
  end

  def import_score(score)
    header = score.header
    Chant.find_or_create_by!(chant_id: header['id'], source_file_path: score.src_file) do |chant|
      chant.lilypond_code = score.text
      chant.lyrics = score.lyrics_readable
      chant.header = header
      %w[quid modus differentia psalmus].each do |key|
        chant.public_send "#{key}=", header[key]
      end
      p chant
    end
  end
end
