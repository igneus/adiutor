desc 'open specified chant in editor'
task :open_in_editor, [:chant_id] => [:environment] do |task, args|
  EditorOpener.new.call Chant.find args.chant_id
end
