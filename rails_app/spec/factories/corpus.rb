FactoryBot.define do
  factory :corpus do
    system_name { 'system_name' }
    name { 'Corpus Name' }

    factory :in_adiutorium_corpus do
      system_name { 'in_adiutorium' }
      name { 'In adiutorium' }
    end
  end
end
