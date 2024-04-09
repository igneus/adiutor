# properties which can be simply fed to Chant.where
CHANTS_FILTER_SIMPLE_WHERE_PROPERTIES = [
  # used in links, but not exposed in the filter form
  :quid,
  :modus,
  :differentia,
  :psalmus,
  :word_count,
  :melody_section_count,

  :genre_id,
  :book_id,
  :corpus_id,
  :cycle_id,
  :season_id,
  :hour_id,
  :source_language_id,
  :music_book_id,

  :alleluia_optional,
  :simple_copy,
]

ChantsFilter = Struct.new(
  *CHANTS_FILTER_SIMPLE_WHERE_PROPERTIES,

  # used in links, but not exposed in the filter form
  :ids,

  :source_file_path,

  :lyrics_edited,
  :mismatch,

  ## properties with special handling:
  :lyrics,
  :lyrics_like_type,
  :case_sensitive,
  :normalized,

  :volpiano,
  :music_search_type,
  :volpiano_like_type,

  :fons_externus,
  :quality_notice,
  :favourite,
) do

  # methods required by #form_for
  include ActiveModel::Conversion
  def persisted?
    false
  end

  def simple_where_attributes
    to_h
    .slice(*CHANTS_FILTER_SIMPLE_WHERE_PROPERTIES)
    .select {|key, val| val.present? }
  end

end
