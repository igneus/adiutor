IMPORT_PREREQUISITES = [
  :environment,
  :create_books, :create_cycles, :create_seasons, :create_corpuses, :create_source_languages, :create_genres
]

desc 'import chants from In-adiutorium sources'
task import: IMPORT_PREREQUISITES do
  InAdiutoriumImporter.new.call Adiutor::IN_ADIUTORIUM_SOURCES_PATH
end

desc 'run import together with subsequent data-building tasks'
task refresh: %i[import update_parents compare_parents missing_images]

desc 'import chants from a specified file'
task :import_file, [:file] => IMPORT_PREREQUISITES do |task, args|
  InAdiutoriumImporter.new.import_file File.join(Adiutor::IN_ADIUTORIUM_SOURCES_PATH, args.file)
end

desc 'create Books'
task create_books: [:environment] do
  Book.find_or_create_by!(system_name: 'dmc', name: 'Denní modlitba církve')
  Book.find_or_create_by!(system_name: 'olm', name: 'Mešní lekcionář')
  Book.find_or_create_by!(system_name: 'other', name: 'Jiné')
  Book.find_or_create_by!(system_name: 'br', name: 'Breviarium Romanum')

  Dir[File.join(Adiutor::IN_ADIUTORIUM_SOURCES_PATH, 'reholni', '*')]
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
  Corpus.find_or_create_by!(system_name: 'la1960', name: 'Liber antiphonarius 1960')
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

desc 'generate Volpiano for all scores'
task volpiano: [:environment] do
  # we can only convert gabc pieces to Volpiano (yet)
  supported_chants =
    Chant
      .joins(:source_language)
      .where(source_languages: { system_name: 'gabc' })

  supported_chants.find_each do |c|
    p c.id

    begin
      volpiano = c.source_language.volpiano_translator&.(c.source_code)
    rescue RuntimeError => e
      STDERR.puts e.message
      next
    end

    c.update!(volpiano: volpiano)
  end
end
