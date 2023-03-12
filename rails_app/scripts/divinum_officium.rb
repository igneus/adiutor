# rails runner scripts/divinum_officium.rb <DO_SOURCES_PATH>
#
# Accepts path to the root directory of the divinum-officium project
# (check it out from https://github.com/DivinumOfficium/divinum-officium ).
# Traverses the data files and prints antiphon texts for which
# we don't have chant notation.

AR1960 = MusicBook.find_by!(title: 'Liber antiphonarius', year: 1960)

def available?(text)
  Chant
    .where(music_book: AR1960, lyrics_normalized: LyricsNormalizer.new.normalize_latin(text))
    .exists?
end

DO_SOURCES_PATH = ARGV[0] || raise('please specify path to divinum-officium sources')

print_all = false

total = 0
missing = 0
Dir[File.join(DO_SOURCES_PATH, *%w(web www horas Latin ** *.txt))].each do |path|
  formulary = DivinumOfficium::Formulary.new(File.read(path))
  next if formulary.antiphons.empty?
  title_printed = false

  formulary
    .antiphons
    .reject(&:is_reference?)
    .each do |antiphon|
    total += 1

    available = available?(antiphon.text)
    missing += 1 unless available
    next if available && !print_all

    unless title_printed
      puts
      puts '= ' + path.sub(DO_SOURCES_PATH, '')
      title_printed = true
    end

    puts (available ? '+' : '-') + ' ' + antiphon.title + ': ' + antiphon.text
  end
end

puts
puts "#{total} antiphons checked, #{missing} missing"
