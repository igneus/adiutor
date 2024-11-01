# Loads random scores from the GregoBase db
# (from the raw GregoBase, not the selected pieces imported in Adiutor),
# outputs them in a format processable by LilyPond+lilygabc.

count = ARGV[0]&.to_i || 5

chants =
  Gregobase::Chant
    .where.not(gabc: '')
    .where.not("gabc LIKE '[%'") # TODO try to reasonably handle those, too
    .order(Arel.sql('RAND()'))
    .limit(count)

puts ApplicationController.renderer.render(
  'scripts/ly_random_gregobase_scores/lilypond',
  locals: {chants: chants},
  layout: false
)
