namespace :antiphonale83 do
  desc 'import chants from antiphonale83 sources'
  task import: IMPORT_PREREQUISITES do
    Corpus.find_by_system_name!('antiphonale83').import!
  end
end
