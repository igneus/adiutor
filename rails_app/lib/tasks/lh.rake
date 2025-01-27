namespace :lh do
  desc 'list chants for which we cannot generate link to the online Liturgia horarum'
  task unavailable_links: :environment do
    link_builder = LiturgiaHorarumLinkBuilder.new

    total = 0
    missing = 0
    Corpus
      .find_by_system_name!('in_adiutorium')
      .chants
      .find_each do |chant|
        total += 1
        if link_builder.date_and_hour(chant).nil?
          puts chant.fial_of_self
          missing += 1
        end
      end

    puts
    puts "Missing #{missing} links of #{total} chants total"
  end
end
