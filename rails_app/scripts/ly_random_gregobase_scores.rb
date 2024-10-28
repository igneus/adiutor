# Loads random scores from the GregoBase db
# (from the raw GregoBase, not the selected pieces imported in Adiutor),
# outputs them in a format processable by LilyPond+lilygabc.

count = ARGV[0]&.to_i || 5

puts <<EOS
\\version "2.24.0"
\\include "gregorian.ly"
\\include "lilygabc.ily"

EOS

Gregobase::Chant
  .where.not(gabc: '')
  .where.not("gabc LIKE '[%'") # TODO try to reasonably handle those, too
  .order(Arel.sql('RAND()'))
  .limit(count)
  .each do |gchant|
    gabc = JSON.parse(gchant.gabc)
    puts "\\markup\\with-url \"https://gregobase.selapa.net/chant.php?id=#{gchant.id}\"" +
         " {#{gchant.id} #{gchant['office-part']}" +
         " \\italic{#{gchant.incipit}}}"
    puts "\\score { \\gabc-vaticana \"#{gabc}\" }"
    puts
  end
