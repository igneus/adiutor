# Operates on the GregoBase db, exports all scores as gabc files,
# grouped by source and genre.
class GregobaseExporter
  def self.call(*args)
    new(*args).call
  end

  def initialize(path)
    @path = path
  end

  def call
    clean_path

    Gregobase::GregobaseSource.all.each do |source|
      source_path = File.join @path, source_dirname(source)
      Dir.mkdir source_path

      source.contained_office_parts.each do |office_part|
        Dir.mkdir File.join(source_path, office_part_dirname(office_part))
      end

      # This workaround is necessary because ActiveRecord doesn't seem to support
      # find_in_batches over a joined relation when there's a table with a composite
      # primary key in between and `gregobase_chant_sources` has composite primary key.
      chant_ids =
        source
          .gregobase_chant_sources
          .joins(:gregobase_chant)
          .select('gregobase_chants.id as cid')
          .collect(&:cid)
      Gregobase::GregobaseChant.where(id: chant_ids).find_each do |chant|
        export_chant(chant, source_path)
      end
    end
  end

  def clean_path
    # TODO: print a warning if the directory is not empty

    FileUtils.mkdir_p @path
    `rm -r #{@path}/*` # TODO: translate this to concise simple Ruby
  end

  def path_suitable_string(str)
    str
      .downcase
      .strip
      .gsub(/\s+/, '_')
      .gsub(/[^\s\w\d]/, '')
  end

  def source_dirname(source)
    source.year.to_s +
      '_' +
      path_suitable_string(source.title)
  end

  def office_part_dirname(office_part)
    x = office_part
    x.blank? ? 'unknown_office_part' : x
  end

  def chant_filename(chant)
    chant.id.to_s +
      '_' +
      path_suitable_string(chant.incipit) +
      '.gabc'
  end

  def header_line(chant, property, header_name=nil)
    return nil if chant.send(property).blank?

    "#{header_name || property}: #{chant.send(property)}"
  end

  def gabc_header(chant)
    r = []
    l = method(:header_line).curry.(chant)
    r << l.(:incipit, 'name')
    %i(office-part mode transcriber commentary).each do |prop|
      r << l.(prop, nil)
    end

    r.compact.join("\n")
  end

  def export_chant(gchant, source_path)
    return if gchant.gabc.start_with? '[' # TODO: add support for these

    # TODO: duplicate functionality in GregobaseImporter
    nabc_lines = gchant.gabc.include?('|') ? "nabc-lines: 1;\n" : ''
    begin
      source = JSON.parse(gchant.gabc)
    rescue => e
      p gchant
      p e
      return
    end
    source = gabc_header(gchant) + "\n" + nabc_lines + "%%\n" + source unless source =~ /^%%\r?$/

    path = File.join source_path, office_part_dirname(gchant.send('office-part')), chant_filename(gchant)
    File.write path, source
  end
end
