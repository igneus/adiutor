module Adiutor
  IN_ADIUTORIUM_SOURCES_PATH = ENV['IN_ADIUTORIUM_SOURCES_PATH'] || raise('required envvar not found')
  EDIT_FIAL_URL = ENV['EDIT_FIAL_URL']
  EDIT_FIAL_SECRET = ENV['EDIT_FIAL_SECRET']
  VEROVIO_LOCAL_PATH = ENV['VEROVIO_LOCAL_PATH']
end
