desc 'print unique chant IDs per hour and genre'
# useful for visual check if hour/genre detection during import works well
task unique_chant_ids: :environment do
  Hour.find_each do |hour|
    puts
    puts hour.name
    Genre.find_each do |genre|
      ids =
        Corpus
          .find_by_system_name!('in_adiutorium')
          .chants
          .where(hour: hour, genre: genre)
          .select(:chant_id)
          .distinct
          .pluck(:chant_id)
      next if ids.empty?
      puts genre.name + ': ' + ids.join(' ')
    end
  end
end
