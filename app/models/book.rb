# Represents a book (real or virtual) the chant's text is taken from.
class Book < ApplicationRecord
  has_many :chants
end
