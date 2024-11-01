# Loads random scores from the GregoBase db
# (from the raw GregoBase, not the selected pieces imported in Adiutor),
# outputs them in a format processable by LilyPond+lilygabc.

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on "--tex", "-t", "Generate LuaLaTeX document comparing Gregorio and lilygabc output"

  # Only relevant for LuaLaTeX.
  # There the include path(s) must be configured in the document.
  opts.on "--include ARG", "-I ARG", "LilyPond include path"
end.parse!(into: options)

count = ARGV[0]&.to_i || 5

chants =
  Gregobase::Chant
    .where.not(gabc: '')
    .where.not("gabc LIKE '[%'") # TODO try to reasonably handle those, too
    .order(Arel.sql('RAND()'))
    .limit(count)

puts ApplicationController.renderer.render(
  'scripts/ly_random_gregobase_scores/' +
    (options[:tex] ? 'latex' : 'lilypond'),
  locals: {chants: chants, include_path: options[:include]},
  layout: false
)
