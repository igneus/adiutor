# Represents a corpus of chants.
class Corpus < ApplicationRecord
  self.table_name = 'corpuses'

  has_many :chants
end
