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

  def self.image_path(chant, with_extension: true)
    "app/assets/images/chants/lilypond/#{chant.id}" + (with_extension ? '.svg' : '')
  end

  delegate :image_path, to: self

  def call(chant)
    # lilypond always adds the '.svg' extension to the provided path, so we omit it
    output_file = image_path chant, with_extension: false
    output_file_full = image_path chant

    lib_lily = File.join Rails.root, 'lib', 'lilypond'

    Tempfile.open('chant') do |f|
      f.puts self.class.buildable_code chant.source_code
      f.flush

      `lilypond -dbackend=svg -dno-point-and-click --include=#{Adiutor::IN_ADIUTORIUM_SOURCES_PATH} --include=#{lib_lily} --output=#{output_file} #{f.path}`
      SvgCropper.(output_file_full) if File.exist? output_file_full
    end
  end
end
