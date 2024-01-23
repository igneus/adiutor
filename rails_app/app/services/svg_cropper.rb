class SvgCropper
  # crops an SVG image
  def self.call(path)
    # options valid for Inkscape 0.92
    `inkscape --verb=FitCanvasToDrawing --verb=FileSave --verb=FileQuit #{path}`
  end
end
