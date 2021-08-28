IMPORT_PREREQUISITES = [:environment, :create_books, :create_cycles, :create_seasons]

desc 'import chants from In-adiutorium sources'
task import: IMPORT_PREREQUISITES do
  InAdiutoriumImporter.new.call Adiutor::IN_ADIUTORIUM_SOURCES_PATH
end

desc 'run import together with subsequent data-building tasks'
task refresh: %i[import update_parents]

desc 'import chants from a specified file'
task :import_file, [:file] => IMPORT_PREREQUISITES do |task, args|
  InAdiutoriumImporter.new.import_file File.join(Adiutor::IN_ADIUTORIUM_SOURCES_PATH, args.file)
end

desc 'create Books'
task create_books: [:environment] do
  Book.find_or_create_by!(system_name: 'dmc', name: 'Denní modlitba církve')
  Book.find_or_create_by!(system_name: 'olm', name: 'Mešní lekcionář')
  Book.find_or_create_by!(system_name: 'other', name: 'Jiné')

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
