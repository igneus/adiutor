class SvgCropper
  EXECUTABLE = 'inkscape'

  # crops an SVG image
  def self.call(path)
    options =
      if inkscape_version < 1
        # tested with Inkscape 0.92
        '--verb=FitCanvasToDrawing --verb=FileSave --verb=FileQuit'
      else
        # tested with Inkscape 1.3
        '--export-overwrite --actions="select-all;page-fit-to-selection;export-type:svg;export-plain-svg;export-do"'
      end

    system "#{EXECUTABLE} #{options} #{path}", exception: true
  end

  def self.inkscape_version
    @iversion ||=
      `#{EXECUTABLE} --version`
        .match(/^Inkscape (\d+)/) {|m| m[1].to_i } \
        || raise('failed to determine Inkscape version')
  end
end
