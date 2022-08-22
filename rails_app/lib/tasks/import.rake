# coding: utf-8
IMPORT_PREREQUISITES = [
  :environment,
  :create_books, :create_cycles, :create_seasons, :create_corpuses, :create_source_languages, :create_genres, :create_hours
]

desc 'import chants from In-adiutorium sources'
task import: IMPORT_PREREQUISITES do
  Corpus.find_by_system_name!('in_adiutorium').import!
end

desc 'run import together with subsequent data-building tasks'
task refresh: %i[import update_parents compare_parents missing_images]

desc 'import chants from a specified file'
task :import_file, [:file] => IMPORT_PREREQUISITES do |task, args|
  sources_path = Corpus.find_by_system_name!('in_adiutorium').sources_path
  InAdiutoriumImporter.new.import_file File.join(sources_path, args.file)
end

desc 'create Books'
task create_books: [:environment] do
  Book.find_or_create_by!(system_name: 'dmc', name: 'Denní modlitba církve')
  Book.find_or_create_by!(system_name: 'olm', name: 'Mešní lekcionář')
  Book.find_or_create_by!(system_name: 'other', name: 'Jiné')
  Book.find_or_create_by!(system_name: 'br', name: 'Breviarium Romanum')
  Book.find_or_create_by!(system_name: 'oco1983', name: 'Ordo cantus officii 1983')

  sources_path = Corpus.find_by_system_name!('in_adiutorium').sources_path

  Dir[File.join(sources_path, 'reholni', '*')]
    .each {|f| p f }
    .select {|f| File.directory? f }
    .each do |f|
    order_shortcut = File.basename f

    Book.find_or_create_by!(system_name: order_shortcut.downcase, name: "Proprium #{order_shortcut}")
  end
end

desc 'create Cycles'
task create_cycles: [:environment] do
  %w(
  Ordinarium
  Psalter
  Temporale
  Sanctorale
  ).each do |name|
    Cycle.find_or_create_by!(system_name: name.downcase, name: name)
  end
end

desc 'create Seasons'
task create_seasons: [:environment] do
  CR::Seasons.each do |s|
    Season.find_or_create_by!(system_name: s.symbol, name: s.name)
  end
end

desc 'create Corpuses'
task create_corpuses: [:environment] do
  Corpus.find_or_create_by!(system_name: 'in_adiutorium', name: 'In adiutorium')
  Corpus.find_or_create_by!(system_name: 'liber_antiphonarius', name: 'Liber antiphonarius 1960')
  Corpus.find_or_create_by!(system_name: 'antiphonale83', name: 'Antiphonale 1983')
end

desc 'create SourceLanguages'
task create_source_languages: [:environment] do
  SourceLanguage.find_or_create_by!(system_name: 'lilypond', name: 'LilyPond')
  SourceLanguage.find_or_create_by!(system_name: 'gabc', name: 'GABC (Gregorio)')
end

desc 'create Genres'
task create_genres: [:environment] do
  Genre.find_or_create_by!(system_name: 'invitatory', name: 'Invitatory')
  Genre.find_or_create_by!(system_name: 'antiphon', name: 'Antiphon')
  Genre.find_or_create_by!(system_name: 'antiphon_psalter', name: 'Psalter antiphon')
  Genre.find_or_create_by!(system_name: 'antiphon_gospel', name: 'Gospel antiphon')
  Genre.find_or_create_by!(system_name: 'antiphon_standalone', name: 'Votive/final/processional antiphon')
  Genre.find_or_create_by!(system_name: 'responsory_short', name: 'Short responsory')
  Genre.find_or_create_by!(system_name: 'responsory_nocturnal', name: 'Nocturnal responsory')
  Genre.find_or_create_by!(system_name: 'varia', name: 'Varia')
end

desc 'create Hours'
task create_hours: [:environment] do
  Hour.find_or_create_by!(system_name: 'readings', name: 'Office of Readings')
  Hour.find_or_create_by!(system_name: 'lauds', name: 'Lauds')
  Hour.find_or_create_by!(system_name: 'daytime', name: 'Daytime Prayer')
  Hour.find_or_create_by!(system_name: 'vespers', name: 'Vespers')
  Hour.find_or_create_by!(system_name: 'compline', name: 'Compline')
end
