class GabcImageGenerator
  DOCUMENT =
    <<~EOS
      \\documentclass[12pt, a4paper]{article}
      \\usepackage{fullpage}
      \\usepackage{fontspec}
      \\setmainfont{Charis SIL}
      \\usepackage[autocompile]{gregoriotex}

      \\begin{document}
      \\pagestyle{empty}
      \\gregorioscore{chant.gabc}
      \\end{document}
    EOS
    .freeze

  def self.image_path(chant, with_extension: true)
    "app/assets/images/chants/gabc/#{chant.id}" + (with_extension ? '.svg' : '')
  end

  delegate :image_path, to: self

  def call(chant)
    output_file_full = image_path chant

    File.write 'chant.gabc', chant.source_code

    File.open('chant.tex', 'w') do |f|
      f.puts DOCUMENT
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
