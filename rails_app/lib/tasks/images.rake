generate_image = lambda do |c|
  generator = c.source_language.image_generator

  puts c.id

  begin
    generator.(c)
  rescue => e
    STDERR.puts "Generating image for Chant #{c.id} failed:"
    STDERR.puts e
  end
end

desc '(re-)generate images for all Chants'
task images: [:environment] do
  pc = Concurrent.processor_count
  executor = Concurrent::ThreadPoolExecutor.new(min_threads: pc, max_threads: pc)

  Chant.includes(:source_language).find_in_batches(batch_size: 100) do |batch|
    futures = batch.collect {|c| Concurrent::Future.execute { generate_image.(c) } }
    futures.each(&:value)
  end
end

desc 'generate images for Chants missing them'
task missing_images: [:environment] do
  pc = Concurrent.processor_count
  executor = Concurrent::ThreadPoolExecutor.new(min_threads: pc, max_threads: pc)

  Chant.includes(:source_language).find_in_batches(batch_size: 100) do |batch|
    futures =
      batch
        .reject {|c| File.exist? c.source_language.image_generator.image_path c }
        .collect {|c| Concurrent::Future.execute(executor: executor) { generate_image.(c) } }
    futures.each(&:value)
  end
end

desc 'generate image for a specified Chant'
task :image, [:chant_id] => [:environment] do |task, args|
  Chant
    .find(args.chant_id)
    .then {|c| c.source_language.image_generator.(c) }
end
