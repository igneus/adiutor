class GabcImageGenerator
  # Takes isolated gabc code of a single score,
  # returns a complete LuaLaTex document which can be compiled
  def self.buildable_code(chant_code)
    music = chant_code.sub(/\A.*?%%/m, '') # strip header

    <<~EOS
      \\documentclass[12pt, a4paper]{article}
      \\usepackage{fullpage}
      \\usepackage{fontspec}
      \\setmainfont{Charis SIL}
      \\usepackage[autocompile]{gregoriotex}

      \\begin{document}
      \\pagestyle{empty}
      \\gabcsnippet{#{music}}
      \\end{document}
    EOS
  end

  def self.image_path(chant, with_extension: true)
    "app/assets/images/chants/gabc/#{chant.id}" + (with_extension ? '.svg' : '')
  end

  delegate :image_path, to: self

  def call(chant)
    output_file_full = image_path chant

    File.open('chant.tex', 'w') do |f|
      f.puts self.class.buildable_code chant.source_code
      f.flush

      output, status =
        Open3.capture2e 'lualatex', '--interaction=batchmode', f.path
      if status != 0
        STDERR.puts output
        raise "#{chant.id}, tmpfile #{f.path} failed (#{status})"
      end

      pdf_path = f.path.sub('.tex', '.pdf')
      `pdftocairo -svg #{pdf_path} #{output_file_full}`
      `inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileQuit #{output_file_full}` if File.exist? output_file_full
    end
  end
end