namespace :antiphonarius do
  desc 'import chants from Liber antiphonarius sources'
  task import: IMPORT_PREREQUISITES do
    LiberAntiphonariusImporter.new.call Adiutor::LIBER_ANTIPHONARIUS_SOURCES_PATH
  end
end
