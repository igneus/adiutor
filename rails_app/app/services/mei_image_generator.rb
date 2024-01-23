class MeiImageGenerator
  def self.image_path(chant, with_extension: true)
    "app/assets/images/chants/mei/#{chant.id}" + (with_extension ? '.svg' : '')
  end

  delegate :image_path, to: self

  def call(chant)
    # developed with Verovio 4.2.0

    cmd =
      if Adiutor::VEROVIO_LOCAL_PATH
        dir = Adiutor::VEROVIO_LOCAL_PATH
        executable = File.join dir, 'tools', 'verovio'
        resources = File.join dir, 'data'

        # (-r: the documented long form --resource-path is in fact
        # not recognized by the executable)
        "#{executable} -r #{resources}"
      else
        'verovio'
      end

    output_file = image_path(chant)
    options = [
      "--outfile #{output_file}",
      '--font Gootville', # font less harshly dissimilar to the LilyPond's one
      '--header none',
      '--footer none',
      '--adjust-page-height', # page only as high as the rendered score
    ]
    options += %w(bottom left right top).collect {|i| "--page-margin-#{i} 0" }

    Tempfile.open('chant') do |f|
      f.puts chant.source_code
      f.flush

      `#{cmd} #{options.join(' ')} #{f.path}`
    end
  end
end
