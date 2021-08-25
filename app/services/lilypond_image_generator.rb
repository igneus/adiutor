class LilypondImageGenerator
  # Takes isolated LilyPond code of a single score,
  # returns a complete document which can be compiled
  def self.buildable_code(chant_code)
    [
      "\\version \"2.19.0\"",
      "\\include \"adiutor_preview_settings.ly\"",
      chant_code.sub(/.*(?=\\score)/, ''),
      '' # end with a newline
    ].join("\n")
  end

  def call(chant)
    # lilypond always adds the '.svg' extension to the provided path, so we omit it
    output_file = "app/assets/images/chants/#{chant.id}"
    output_file_full = output_file + '.svg'

    lib_lily = File.join Rails.root, 'lib', 'lilypond'

    Tempfile.open('chant') do |f|
      f.puts self.class.buildable_code chant.lilypond_code
      f.flush

      `lilypond -dbackend=svg -dno-point-and-click --include=#{Adiutor::IN_ADIUTORIUM_SOURCES_PATH} --include=#{lib_lily} --output=#{output_file} #{f.path}`
      `inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileQuit #{output_file_full}` if File.exist? output_file_full
    end
  end
end
