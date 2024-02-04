namespace :neuma do
  desc 'list corpora available in Neuma'
  task list: :environment do
    require 'facets/string/indent'

    Neuma::Corpus.all.each do |corpus|
      puts "- [#{corpus.ref}]: #{corpus.title}"
      puts corpus.description.indent(2)
    end
  end

  desc 'list opera in a specified subcorpus'
  task :opera, [:subcorpus] => :environment do |task, args|
    Neuma::Corpus.opera(args.subcorpus).each do |opus|
      puts "- [#{opus.ref}]: #{opus.title}"
    end
  end

  desc 'fetch MEI files for the relevant sub-corpora'
  task fetch: :environment do
    dir = ENV['NEUMA_SOURCES_PATH'] || 'neuma_files'
    FileUtils.mkdir_p 'neuma_files'

    client = Neuma::Client.new

    client.subcorpora.each do |corpus|
      next unless %w(benedictines1664 franciscains1773).include? corpus.ref
      puts "\nCorpus #{corpus.ref}\n"

      corpus_dir = File.join dir, corpus.ref
      FileUtils.mkdir_p corpus_dir

      client.opera(corpus.ref).each do |o|
        puts "##{o.ref} #{o.title}"

        file =
          o.files.find {|i| i['name'] == 'mei.xml' } ||
          begin
            puts 'MEI file not found'
            next
          end
        dest_path = File.join(corpus_dir, "#{o.ref}.xml")
        next if File.exist? dest_path

        begin
          mei = Faraday.get(file['url']).body
          raise 'empty body' if mei.strip.empty?

          File.write dest_path, mei
        rescue => e
          puts e
          next
        end

        sleep rand 3
      end
    end
  end

  desc 'import chants'
  task import: IMPORT_PREREQUISITES do
    Corpus.find_by_system_name!('neuma').import!
  end
end
