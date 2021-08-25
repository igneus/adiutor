class LilypondImageGenerator
  def call(chant)
    # lilypond always adds the '.svg' extension to the provided path, so we omit it
    output_file = "app/assets/images/chants/#{chant.id}"
    output_file_full = output_file + '.svg'

    Tempfile.open('chant') do |f|
      f.puts chant_lily chant
      f.flush

      `lilypond -dbackend=svg -dno-point-and-click --include=#{Adiutor::IN_ADIUTORIUM_SOURCES_PATH} --output=#{output_file} #{f.path}`
      `inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileQuit #{output_file_full}` if File.exist? output_file_full
    end
  end

  private

  def chant_lily(chant)
    [
      "\\version \"2.19.0\"",
      "\\include \"spolecne.ly\"",
      "\\include \"dilyresponsorii.ly\"",
      "\\header { tagline = ##f }",
      "\\paper { left-margin = 0\\cm   right-margin = 0\\cm   top-margin = 0\\cm   bottom-margin = 0\\cm }",
      chant.lilypond_code
    ].join("\n")
  end
end
