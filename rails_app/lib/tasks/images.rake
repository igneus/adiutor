desc '(re-)generate images for all Chants'
task images: [:environment] do
  Chant.find_each {|c| puts c.id; c.source_language.image_generator.(c) }
end

desc 'generate images for Chants missing them'
task missing_images: [:environment] do
  Chant.find_each do |c|
    generator = c.source_language.image_generator
    next if File.exist? generator.image_path c

    puts c.id

    begin
      generator.(c)
    rescue => e
      STDERR.puts "Generating image for Chant #{c.id} failed:"
      STDERR.puts e
    end
  end
end

desc 'generate image for a specified Chant'
task :image, [:chant_id] => [:environment] do |task, args|
  Chant
    .find(args.chant_id)
    .then {|c| c.source_language.image_generator.(c) }
end
