def unique_chant_ids(relation)
  relation
    .select(:chant_id)
    .distinct
    .pluck(:chant_id)
    .sort
end

desc 'print unique chant IDs per hour and genre'
# useful for visual check if hour/genre detection during import works well
task unique_chant_ids: :environment do
  corpus_chants =
    Corpus
      .find_by_system_name!('in_adiutorium')
      .chants

  Hour.find_each do |hour|
    puts
    puts hour.name
    Genre.find_each do |genre|
      ids = unique_chant_ids(
        corpus_chants.where(hour: hour, genre: genre)
      )

      next if ids.empty?
      puts genre.name + ': ' + ids.join(' ')
    end
  end

  puts
  puts 'No genre: ' +
       unique_chant_ids(corpus_chants.where(genre: nil)).join(' ')
  puts 'No hour: ' +
       unique_chant_ids(corpus_chants.where(hour: nil)).join(' ')
end
