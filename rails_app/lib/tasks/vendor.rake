desc 'update code copied from other codebases'
task vendor_update: [:environment] do
  # code copied from the In-adiutorium repository
  vendor_dir = Rails.root.join('vendor', 'inadiutorium')
  [
    'fial.rb',
    'lib/checkcopies/'
  ].each do |f|
    dir = vendor_dir.join(File.dirname(f))
    FileUtils.mkdir_p dir

    FileUtils.cp_r(
      File.join(Adiutor::IN_ADIUTORIUM_SOURCES_PATH, 'nastroje', f),
      dir
    )
  end
end
