desc 'generate images for Chants'
task images: [:environment] do
  generator = LilypondImageGenerator.new
  Chant.find_each {|c| generator.(c) }
end

desc 'generate image for a specified Chant'
task :image, [:chant_id] => [:environment] do |task, args|
  LilypondImageGenerator.new.(
    Chant.find(args.chant_id)
  )
end
