class LilypondImageGenerator
  def call(chant)
    # lilypond always adds the '.svg' extension to the provided path, so we omit it
    output_file = "app/assets/images/chants/#{chant.id}"

    Tempfile.open('chant') do |f|
      f.puts chant_lily chant
      f.flush

      `lilypond -dbackend=svg -dno-point-and-click --output=#{output_file} #{f.path}`
    end
  end

  private

  def chant_lily(chant)
    [
      "\\version \"2.19.0\"",
      include_statement('spolecne.ly'),
      include_statement('dilyresponsorii.ly'),
      "\\header { tagline = ##f }",
      "\\paper { left-margin = 0\\cm   right-margin = 0\\cm   top-margin = 0\\cm   bottom-margin = 0\\cm }",
      chant.lilypond_code
    ].join("\n")
  end

  def include_statement(ia_path)
    full_path = File.join(ENV['IN_ADIUTORIUM_SOURCES_PATH'], ia_path)

    "\\include \"#{full_path}\""
  end
end
