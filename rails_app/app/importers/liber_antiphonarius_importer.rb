# coding: utf-8
# Imports chants from the directory structure of Liber antiphonarius 1960
# transcribed by Andrew Hinkley
# https://github.com/ahinkley/liber-antiphonarius-1960
class LiberAntiphonariusImporter < BaseImporter
  include GabcImporter

  def call(path)
    corpus.imports.build.do! do |import|
      %w(AN RE)
        .flat_map {|genre| Dir["#{path}/#{genre}/**/*.gabc"] }
        .each {|f| import_file f, path, import }
    end

    report_unseen_chants
  end

  def import_file(path, dir, import)
    p path
    in_project_path = path.sub(dir, '').sub(/^\//, '')

    source = File.read path
    begin
      score = SimpleGabcParser.call source
    rescue RuntimeError => e
      STDERR.puts "failed to parse '#{path}': #{e.message}"
      return # just skip the failed score
    end

    header = score.header.to_hash.transform_values {|v| v == '' ? nil : v }
    page = page_from_header_book header['book']

    book = Book.find_by_system_name! 'br'
    language = SourceLanguage.find_by_system_name! 'gabc'

    cycle = cycle_by_page(page)
    season = season_by_page(page)

    chant = Chant.find_or_initialize_by(chant_id: '1', source_file_path: in_project_path)

    chant.corpus = corpus
    chant.import = import
    chant.book = book
    chant.cycle = cycle
    chant.season = season
    chant.source_language = language
    chant.genre = detect_genre header, cycle

    chant.source_code = source
    chant.lyrics =
      LyricsHelper
        .normalize_initial(score.music.lyrics_readable)
        .gsub(%r{\s*<sp>[VR]/</sp>\.?\s*}, ' ')
    chant.lyrics_normalized =
      score.music.lyrics_readable
        .gsub(%r{\s*<sp>([VR])/</sp>\.?\s*}) {|m| Regexp.last_match[1] == 'V' ? ' | ' : ' ' }
        .gsub(%r{\s*<i>.*?</i>\s*}, ' ')
        .yield_self {|l| l[0 ... l.rindex('Glória Patri')] }
        .yield_self {|l| LyricsNormalizer.new.normalize_latin l }
    chant.alleluia_optional = !!(score.music.lyrics_readable =~ /T\.\s*P\./)
    chant.header = header

    header_mode = header['mode']
    chant.modus =
      case header_mode
      when nil
        nil
      when /^\d+$/
        RomanNumerals.to_roman(header_mode.to_i)
      when /^per/i
        header_mode
          .sub(/\.$/, '')
          .downcase
      else
        header_mode
      end

    extract_stats(chant, score)

    chant.save!
  end

  PageNumber = Struct.new(:number, :prefix, :suffix) do
    def in_range?(range, prefix=nil)
      self.prefix == prefix && range.include?(number)
    end
  end

  def page_from_header_book(value)
    value.match(/.+?, pp (\[)?(\d+)(\*)?/) {|m| PageNumber.new(m[2].to_i, m[1], m[3]) } || raise("page not found in #{value.inspect}")
  end

  def cycle_by_page(page)
    system_name =
      if page.in_range?(1..209)
        'psalter'
      elsif page.in_range?(210..576)
        'temporale'
      elsif page.in_range?(577..931) || page.in_range?(1..141, '[')
        'sanctorale'
      elsif page.suffix == '*'
        'ordinarium'
      else
        'temporale' # TODO
      end

    Cycle.find_by_system_name! system_name
  end

  def season_by_page(page)
    # here we pragmatically impose post-Vatican II notions of liturgical seasons,
    # since the material is being imported for purposes of comparison
    # with the vernacular chants for a post-Vatican II LOTH
    system_name =
      if page.in_range?(210..258)
        'advent'
      elsif page.in_range?(259..335)
        'christmas'
      elsif page.in_range?(336..340)
        'ordinary'
      elsif page.in_range?(341..431)
        'lent'
      elsif page.in_range?(432..447)
        'triduum'
      elsif page.in_range?(448..515)
        'easter'
      elsif page.in_range?(516..576)
        'ordinary'
      else
        nil
      end

    system_name && Season.find_by_system_name!(system_name)
  end

  def detect_genre(header, cycle)
    office_part = header['office-part']

    genre =
      if office_part == 'Responsoria brevia'
        'responsory_short'
      elsif office_part == 'Antiphonae'
        # TODO: there is currently no easy and general way to detect gospel antiphons
        if cycle.system_name == 'psalter'
          'antiphon_psalter'
        else
          'antiphon'
        end
      else
        'varia'
      end

    Genre.find_by_system_name!(genre)
  end
end
