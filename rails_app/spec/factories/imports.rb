FactoryBot.define do
  factory :import do
    factory :started_import do
      started_at { Time.mktime(2020, 2, 1, 0, 0, 0) }
    end
  end
end
