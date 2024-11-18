# coding: utf-8
IMPORT_PREREQUISITES = [
  :environment,
  :'db:seed'
]

# Hardcode Corpus system names, so we don't have to touch the database
# in order to generate tasks for each Corpus.
CORPUS_SYSTEM_NAMES = %w(
  in_adiutorium
  liber_antiphonarius
  antiphonale83
  gregobase
  nocturnale
  hughes
  neuma
)

CORPUS_SYSTEM_NAMES.each do |system_name|
  namespace system_name do
    desc 'check that the Corpus is configured and can be imported'
    task setup_check: IMPORT_PREREQUISITES do
      unless Corpus.find_by_system_name(system_name).configured?
        abort "ERROR: Corpus is not configured.\nUsually this means you should go to .env and set an environment variable to the path of the corpus data."
      end
    end

    corpus_import_prerequisites = IMPORT_PREREQUISITES + ["#{system_name}:setup_check"]

    desc 'import chants'
    task import: corpus_import_prerequisites do
      Corpus.find_by_system_name!(system_name).import!
    end

    desc 'delete chants not seen by the last import'
    task delete_unseen_chants: corpus_import_prerequisites do
      delendi = Corpus.find_by_system_name!(system_name).chants_unseen_by_last_import

      delendi.each do |c|
        puts "- ##{c.id} #{c.lyrics}"
      end
      puts

      print "Delete #{delendi.size} chants? (type 'yes') "
      exit if STDIN.gets.chomp != 'yes'

      delendi.destroy_all
      puts "Chants deleted."
    end

    desc '(re-)generate images for all Chants'
    task images: corpus_import_prerequisites do
      Rake::Task["images:for_corpus"].invoke(system_name)
    end

    desc 'generate images for Chants missing them'
    task images_missing: corpus_import_prerequisites do
      Rake::Task["images:missing_for_corpus"].invoke(system_name)
    end

    desc 'run import and all subsequent tasks to refresh the corpus'
    task refresh: ["#{system_name}:import", "#{system_name}:images_missing"]
  end
end

# Specific to the In adiutorium corpus:

# additional prerequisites
Rake::Task['in_adiutorium:refresh']
  .enhance %i[parents:update parents:compare parents:update_children_tree_size]

desc 'import chants from a specified file'
task :import_file, [:file] => IMPORT_PREREQUISITES do |task, args|
  sources_path = Corpus.find_by_system_name!('in_adiutorium').sources_path
  InAdiutoriumImporter.new.import_file File.join(sources_path, args.file)
end

# convenience shortcuts for the most frequently imported corpus

desc 'import chants from In-adiutorium sources'
task import: :'in_adiutorium:import'

desc 'run import together with subsequent data-building tasks'
task refresh: :'in_adiutorium:refresh'
