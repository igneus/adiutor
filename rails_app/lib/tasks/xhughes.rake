namespace :hughes do
  desc 'import chants from Andrew Hughes sources'
  task import: IMPORT_PREREQUISITES do
    Corpus.find_by_system_name!('hughes').import!
  end
end
