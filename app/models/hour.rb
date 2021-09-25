# One of the hours (prayers said in the course of the day)
# of the Liturgy of the Hours.
class Hour < ApplicationRecord
  has_many :chants
end
