desc 'import chants from In-adiutorium sources'
task import: [:environment, :create_books] do
  InAdiutoriumImporter.new.call Adiutor::IN_ADIUTORIUM_SOURCES_PATH
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
