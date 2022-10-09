# Represents a liturgical book the chant's *text* is taken from.
class Book < ApplicationRecord
  has_many :chants
end
