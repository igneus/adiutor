module Adiutor
  IN_ADIUTORIUM_SOURCES_PATH = ENV['IN_ADIUTORIUM_SOURCES_PATH'] || raise('required envvar not found')
  LIBER_ANTIPHONARIUS_SOURCES_PATH = ENV['LIBER_ANTIPHONARIUS_SOURCES_PATH'] || raise('required envvar not found')
end
