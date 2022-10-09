# A notated chant book.
# (Breviary is a Book, antiphonal is a MusicBook.
# There are some cases where the notated book is at the same time
# the one and only official source of text, then it may be
# represented both by a Book and MusicBook instance.
# Not all chants must belong to a MusicBook - MusicBook is important
# mostly for structuring corpora which contain transcriptions of multiple sources.)
class MusicBook < ApplicationRecord
  belongs_to :corpus

  # Neither alias, nor alias_method can be used to alias an ActiveRecord property -
  # attempts to do so result in weird NameErrors
  def name
    title
  end
end
