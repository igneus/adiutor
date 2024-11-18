# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# IMPORTANT: in this application seeds are used not only for initialization of a new
# database, but also for adding new entries later on.
# Don't expect the database to be empty and always make sure that the entry in question
# doesn't already exist.

# Corpora

Corpus.find_or_create_by!(system_name: 'in_adiutorium', name: 'In adiutorium')
Corpus.find_or_create_by!(system_name: 'liber_antiphonarius', name: 'Liber antiphonarius 1960')
Corpus.find_or_create_by!(system_name: 'antiphonale83', name: 'Antiphonale 1983')
Corpus.find_or_create_by!(system_name: 'gregobase', name: 'GregoBase')
Corpus.find_or_create_by!(system_name: 'nocturnale', name: 'nocturnale.marteo.fr')
Corpus.find_or_create_by!(system_name: 'hughes', name: 'Andrew Hughes')
Corpus.find_or_create_by!(system_name: 'neuma', name: 'Neuma')
Corpus.find_or_create_by!(system_name: 'echoes', name: 'Echoes from the Past (Aquitanian chant)')

# Books

Book.find_or_create_by!(system_name: 'dmc', name: 'Denní modlitba církve')
Book.find_or_create_by!(system_name: 'olm', name: 'Mešní lekcionář')
Book.find_or_create_by!(system_name: 'other', name: 'Jiné')
Book.find_or_create_by!(system_name: 'br', name: 'Breviarium Romanum')
Book.find_or_create_by!(system_name: 'bm', name: 'Breviarium Monasticum')
Book.find_or_create_by!(system_name: 'lhm', name: 'Liturgia horarum monastica')
Book.find_or_create_by!(system_name: 'bsop', name: 'Breviarium S.O.P.') # Sacri Ordinis Praedicatorum
Book.find_or_create_by!(system_name: 'bcist', name: 'Breviarium Cisterciense')
Book.find_or_create_by!(system_name: 'oco1983', name: 'Ordo cantus officii 1983')
Book.find_or_create_by!(system_name: 'oco2015', name: 'Ordo cantus officii 2015') # promulgation decree dated 2014, but book published 2015
Book.find_or_create_by!(system_name: 'gs', name: 'Graduale simplex')

sources_path = Corpus.find_by_system_name!('in_adiutorium').sources_path
unless sources_path.blank?
  Dir[File.join(sources_path, 'reholni', '*')]
    .each {|f| p f }
    .select {|f| File.directory? f }
    .each do |f|
    order_shortcut = File.basename f

    Book.find_or_create_by!(system_name: order_shortcut.downcase, name: "Proprium #{order_shortcut}")
  end
end

# Cycles

%w(
  Ordinarium
  Psalter
  Temporale
  Sanctorale
).each do |name|
  Cycle.find_or_create_by!(system_name: name.downcase, name: name)
end

# Seasons

CR::Seasons.each do |s|
  Season.find_or_create_by!(system_name: s.symbol, name: s.name)
end

# SourceLanguages

SourceLanguage.find_or_create_by!(system_name: 'lilypond', name: 'LilyPond')
SourceLanguage.find_or_create_by!(system_name: 'gabc', name: 'GABC (Gregorio)')
SourceLanguage.find_or_create_by!(system_name: 'mei', name: 'MEI')

# Genres

Genre.find_or_create_by!(system_name: 'invitatory', name: 'Invitatory')
Genre.find_or_create_by!(system_name: 'antiphon', name: 'Antiphon')
Genre.find_or_create_by!(system_name: 'antiphon_psalter', name: 'Psalter antiphon')
Genre.find_or_create_by!(system_name: 'antiphon_gospel', name: 'Gospel antiphon')
Genre.find_or_create_by!(system_name: 'antiphon_standalone', name: 'Votive/final/processional antiphon')
Genre.find_or_create_by!(system_name: 'responsory_short', name: 'Short responsory')
Genre.find_or_create_by!(system_name: 'responsory_nocturnal', name: 'Nocturnal responsory')
Genre.find_or_create_by!(system_name: 'hymn', name: 'Hymn')
Genre.find_or_create_by!(system_name: 'varia', name: 'Varia')

# Hours

Hour.find_or_create_by!(system_name: 'readings', name: 'Office of Readings')
Hour.find_or_create_by!(system_name: 'lauds', name: 'Lauds')
Hour.find_or_create_by!(system_name: 'daytime', name: 'Daytime Prayer')
Hour.find_or_create_by!(system_name: 'vespers', name: 'Vespers')
Hour.find_or_create_by!(system_name: 'compline', name: 'Compline')
