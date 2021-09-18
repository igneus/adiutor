# Language in which a chant's (primary) source code is encoded.
class SourceLanguage < ApplicationRecord
  has_many :chants
end
