namespace :antiphonarius do
  desc 'import chants from Liber antiphonarius sources'
  task import: IMPORT_PREREQUISITES do
    Corpus.find_by_system_name!('liber_antiphonarius').import!
  end
end
