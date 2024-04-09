require 'reform/form/coercion'

class ChantsFilterForm < Reform::Form
  feature Coercion

  %i[
    quid
    modus
    differentia
    psalmus
    lyrics
    lyrics_like_type
    volpiano
    music_search_type
    volpiano_like_type
    source_file_path
  ].each do |i|
    property i, type: Types::Coercible::String
  end

  property :word_count, type: Types::Params::Integer
  property :melody_section_count, type: Types::Params::Integer

  array_of_integers = Types::Array.of(Types::Params::Integer)
  %i[
    genre_id
    book_id
    corpus_id
    cycle_id
    season_id
    hour_id
    source_language_id
    music_book_id
    ids
  ].each do |i|
    property i, type: array_of_integers
  end

  %i[
    alleluia_optional
    simple_copy
    case_sensitive
    normalized
    lyrics_edited
    fons_externus
    quality_notice
    favourite
    show_placet
    mismatch
  ].each do |i|
    property i, type: Types::Params::Bool
  end
end
