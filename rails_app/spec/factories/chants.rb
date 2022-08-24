FactoryBot.define do
  # minimal instance which can be persisted
  factory :chant do
    book
    cycle
    corpus
    source_language
    genre
  end
end
