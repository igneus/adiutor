# coding: utf-8
IMPORT_PREREQUISITES = [
  :environment,
  :'db:seed'
]

desc 'import chants from In-adiutorium sources'
task import: IMPORT_PREREQUISITES do
  Corpus.find_by_system_name!('in_adiutorium').import!
end

desc 'import chants not seen by the last import'
task delete_unseen_chants: :environment do
  delendi = Corpus.find_by_system_name!('in_adiutorium').chants_unseen_by_last_import

  delendi.each do |c|
    puts "- ##{c.id} #{c.lyrics}"
  end
  puts

  print "Delete #{delendi.size} chants? (type 'yes') "
  exit if STDIN.gets.chomp != 'yes'

  delendi.destroy_all
  puts "Chants deleted."
end

desc 'run import together with subsequent data-building tasks'
task refresh: %i[import update_parents compare_parents update_children_tree_size images:missing]

desc 'import chants from a specified file'
task :import_file, [:file] => IMPORT_PREREQUISITES do |task, args|
  sources_path = Corpus.find_by_system_name!('in_adiutorium').sources_path
  InAdiutoriumImporter.new.import_file File.join(sources_path, args.file)
end
