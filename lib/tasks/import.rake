desc 'import chants from In-adiutorium sources'
task import: [:environment] do
  InAdiutoriumImporter.new.call ENV['IN_ADIUTORIUM_SOURCES_PATH']
end
