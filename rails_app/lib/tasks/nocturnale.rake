namespace :nocturnale do
  desc 'import chants from Nocturnale Romanum sources'
  task import: IMPORT_PREREQUISITES do
    Corpus.find_by_system_name!('nocturnale').import!
  end
end
