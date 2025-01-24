FactoryBot.define do
  factory :gregobase_source, class: 'Gregobase::Source' do
    editor { Faker::Book.publisher }
    title { Faker::Book.title }
    description { Faker::Lorem.sentence }
    caption { Faker::Lorem.sentence }
  end
end
