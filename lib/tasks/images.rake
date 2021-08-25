desc '(re-)generate images for all Chants'
task images: [:environment] do
  generator = LilypondImageGenerator.new
  Chant.find_each {|c| generator.(c) }
end

desc 'generate images for Chants missing them'
task missing_images: [:environment] do
  generator = LilypondImageGenerator.new
  Chant.find_each do |c|
    next if File.exist? LilypondImageGenerator.image_path c

    generator.(c)
  end
end

desc 'generate image for a specified Chant'
task :image, [:chant_id] => [:environment] do |task, args|
  LilypondImageGenerator.new.(
    Chant.find(args.chant_id)
  )
end
