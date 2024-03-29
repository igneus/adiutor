namespace :check do
  desc 'list texts which have multiple unrelated settings'
  task multiple_settings: :environment do
    result = MultipleSettingsFinder.new.call

    result.each do |i|
      puts "#{i.group_size} #{i.lyrics_further_normalized} "
      # TODO: list IDs of the chants in the group
      # TODO: url to a listing showing the chants in the group
      # TODO: signal if there are chants of different genres
    end

    puts "Nothing found (that's good)" if result.empty?
  end

  desc 'list chants with multiple +aleluja children'
  task multiple_child_alleluias: :environment do
    Chant
      .top_parents
      .collect {|parent| [parent, parent.posterity.select {|i| i.fial.include? '+aleluja' }.count] }
      .select {|(parent, plus_alleluias)| plus_alleluias > 1 }
      .tap {|result| puts "Nothing found (that's good)" if result.empty? }
      .each do |(parent, plus_alleluias)|
      puts "##{parent.id}: #{plus_alleluias}"
    end
  end

  task all: [
         :multiple_settings,
         :multiple_child_alleluias,
       ]
end
