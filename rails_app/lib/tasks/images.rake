module ImageTaskUtils
  extend self

  def generate_image(c)
    generator = c.source_language.image_generator

    puts c.id

    begin
      generator.(c)
    rescue => e
      STDERR.puts "Generating image for Chant #{c.id} failed:"
      STDERR.puts e
    end
  end

  def concurrently_generate_images(chants, missing_only: false)
    pc = Concurrent.processor_count
    executor = Concurrent::ThreadPoolExecutor.new(min_threads: pc, max_threads: pc)

    filter =
      if missing_only
        -> (chants) { chants.reject {|c| File.exist? c.source_language.image_generator.image_path c } }
      else
        :itself.to_proc
      end

    chants.includes(:source_language).find_in_batches(batch_size: 100) do |batch|
      futures =
        batch
          .then {|b| filter.(b) }
          .collect {|c| Concurrent::Future.execute(executor: executor) { generate_image(c) } }
      futures.each(&:value)
    end
  end
end

namespace :images do
  desc '(re-)generate images for all Chants'
  task all: [:environment] do
    ImageTaskUtils.concurrently_generate_images(Chant)
  end

  desc 'generate images for Chants missing them'
  task missing: [:environment] do
    ImageTaskUtils.concurrently_generate_images(Chant, missing_only: true)
  end

  task :for_corpus, [:corpus_system_name] => [:environment] do |task, args|
    ImageTaskUtils.concurrently_generate_images(
      Corpus.find_by_system_name(args.corpus_system_name).chants
    )
  end

  task :missing_for_corpus, [:corpus_system_name] => [:environment] do |task, args|
    ImageTaskUtils.concurrently_generate_images(
      Corpus.find_by_system_name(args.corpus_system_name).chants,
      missing_only: true
    )
  end

  desc 'list images of chants which no longer exist in the database'
  task orphaned: :environment do
    paths = Dir[Rails.root + 'app/assets/images/chants/*/*.svg']

    count = 0
    paths.each do |path|
      id = File.basename(path).to_i
      unless Chant.exists? id
        puts path
        count += 1
      end
    end

    # print to stderr so stdout contains only paths
    # and can be directly piped e.g. to `xargs rm`
    STDERR.puts "#{count} orphaned images total"
  end
end

desc 'generate image for a specified Chant'
task :image, [:chant_id] => [:environment] do |task, args|
  Chant
    .find(args.chant_id)
    .then {|c| c.source_language.image_generator.(c) }
end
