# rails runner scripts/divinum_officium.rb <DO_SOURCES_PATH>
#
# Accepts path to the root directory of the divinum-officium project
# (check it out from https://github.com/DivinumOfficium/divinum-officium ).
# Traverses the data files and prints antiphon texts for which
# we don't have chant notation.

require 'optparse'

parser = OptionParser.new do |opts|
  opts.separator 'Chant texts to check'
  opts.on '-M', '--no-monastic', 'Do not scan data files of the monastic office'

  opts.separator 'Music sources to consider'
  opts.on '-b', '--any-book', 'Consider chants from all imported books'

  opts.separator 'Output'
  opts.on '-a', '--print-all', 'Print also available antiphons'
end



AR1960 = MusicBook.find_by!(title: 'Liber antiphonarius', year: 1960)

# do we have notation for the specified chant text?
def available?(text, any_book: false)
  args = {lyrics_normalized: LyricsNormalizer.new.normalize_latin(text)}
  args[:music_book] = AR1960 unless any_book

  Chant.where(**args).exists?
end

# is the data file in question specific for the monastic office?
def monastic_path?(path)
  path =~ /(Tempora|Sancti|Commune)M/
end



options = {}
parser.parse!(into: options)

DO_SOURCES_PATH = ARGV[0] || raise('please specify path to divinum-officium sources')

total = 0
missing = 0
Dir[File.join(DO_SOURCES_PATH, *%w(web www horas Latin ** *.txt))].each do |path|
  next if options.has_key?(:'no-monastic') && monastic_path?(path)

  formulary = DivinumOfficium::Formulary.new(File.read(path))
  title_printed = false

  formulary
    .antiphons
    .reject(&:is_reference?)
    .each do |antiphon|
    total += 1

    available = available?(antiphon.text, any_book: options[:'any-book'])
    missing += 1 unless available
    next if available && !options[:'print-all']

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
