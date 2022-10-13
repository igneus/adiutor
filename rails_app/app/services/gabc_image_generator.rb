class GabcImageGenerator
  def self.latex_document(gabc_filename)
    <<~EOS
      \\documentclass[12pt, a4paper]{article}
      \\usepackage{fullpage}
      \\usepackage{fontspec}
      \\setmainfont{Charis SIL}
      \\usepackage[autocompile]{gregoriotex}

      \\begin{document}
      \\pagestyle{empty}
      \\gregorioscore{#{gabc_filename}}
      \\end{document}
    EOS
  end

  def self.image_path(chant, with_extension: true)
    "app/assets/images/chants/gabc/#{chant.id}" + (with_extension ? '.svg' : '')
  end

  delegate :image_path, to: self

  def call(chant)
    output_file_full = image_path chant

    gabc_filename = "#{chant.id}.gabc"
    File.write gabc_filename, chant.source_code

    tex_filename = "#{chant.id}.tex"
    File.open(tex_filename, 'w') do |f|
      f.puts self.class.latex_document gabc_filename
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

    File.unlink gabc_filename
    File.unlink tex_filename
  end
end
