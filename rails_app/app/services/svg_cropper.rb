class SvgCropper
  # crops an SVG image
  def self.call(path)
    # options valid for Inkscape 0.92
    #`inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileQuit #{path}`

    # options valid for Inkscape 1.3
    `inkscape --export-overwrite --actions="select-all;page-fit-to-selection;export-type:svg;export-plain-svg;export-do" #{path}`
  end
end
