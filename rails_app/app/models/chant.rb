class Chant < ApplicationRecord
  belongs_to :book
  belongs_to :music_book, optional: true
  belongs_to :cycle, optional: true
  belongs_to :season, optional: true
  belongs_to :corpus
  belongs_to :import, optional: true
  belongs_to :source_language
  belongs_to :genre
  belongs_to :hour, optional: true
  belongs_to :parent, class_name: 'Chant', optional: true
  has_many :children, class_name: 'Chant', foreign_key: 'parent_id'
  has_many :mismatches, class_name: 'ParentChildMismatch', foreign_key: 'child_id'

  IS_FAVOURITE_COND = "placet LIKE '*%'"
  scope :to_be_fixed, -> { where.not(placet: nil).where.not(IS_FAVOURITE_COND) }
  scope :favourite, -> { where(IS_FAVOURITE_COND) }

  scope :unique, -> { where(simple_copy: false, copy: false) }
  scope :copies_first, -> do
    order(Arel.sql('CASE
      WHEN simple_copy IS TRUE THEN 1
      WHEN copy IS TRUE THEN 2
      ELSE 3 END'))
  end

  scope :all_antiphons, -> { joins("INNER JOIN genres ON chants.genre_id = genres.id AND system_name LIKE 'antiphon%'") }

  scope :have_fons_externus, -> { where("header->'fons_externus' IS NOT NULL") }

  scope :obsolete, -> {
    joins(
      'INNER JOIN corpuses
      ON chants.corpus_id = corpuses.id
      AND chants.import_id !=
        (SELECT id FROM imports WHERE corpus_id = corpuses.id ORDER BY started_at DESC LIMIT 1)'
    )
  }

  scope :top_parents, -> do
    all_parents = select(:parent_id).distinct.where.not(parent_id: nil)
    where(parent_id: nil).where("id IN (#{all_parents.to_sql})")
  end

  # Properties containing music encoded in Volpiano and other related encoding systems
  VOLPIANO_PROPERTIES = [
    :volpiano,
    :pitch_series,
    :interval_series,
    :ambitus_min_note,
    :ambitus_max_note,
    :ambitus_interval,
  ].freeze

  # @return Hash<String => Array<Chant>>
  #   the Chant instances have populated only properties modus, differentia and (ad hoc property) record_count
  def self.modi_and_differentiae
    select(:modus, :differentia, 'count(id) as record_count')
      .group(:modus, :differentia)
      .order(:modus, :differentia)
      .group_by(&:modus)
  end

  def self.similar_by_structure_to(chant, limit=5)
    where(genre: chant.genre)
      .where.not(id: chant.id)
      .order(Arel.sql("ABS(melody_section_count - #{chant.melody_section_count || 0})"))
      .limit(limit)
  end

  def self.similar_by_lyrics_length_to(chant, limit=5)
    where(genre: chant.genre)
      .where.not(id: chant.id)
      .order(Arel.sql("LEAST(ABS(word_count - #{chant.word_count || 0}), ABS(syllable_count - #{chant.syllable_count || 0}))"))
      .limit(limit)
  end

  # To each calendar date assigns a single Chant marked for revision.
  def self.chant_of_the_day(date)
    tbf = Chant.to_be_fixed
    count = tbf.count
    return nil if count == 0

    tbf
      .order(:id)
      .offset(date.jd % count)
      .limit(1)
      .first
  end

  def self.filtered_by_lyrics(lyrics_input, case_sensitive: true, normalized: false, lyrics_like_type:)
    column = 'lyrics'
    like = case_sensitive ? 'LIKE' : 'ILIKE'

    if normalized
      column = 'lyrics_normalized'
      # using `normalize_czech` assumes that the user will usually use simple keyboard
      # input and abstain from entering special Latin stuff like accented digraphs
      lyrics_input = LyricsNormalizer.new.normalize_czech lyrics_input
    end

    lyrics_like_str = SearchUtils.like_search_string(lyrics_input, lyrics_like_type)

    self.where("#{column} #{like} ? OR textus_approbatus #{like} ?", lyrics_like_str, lyrics_like_str)
  end

  def self.filtered_by_melody(volpiano, music_search_type:, volpiano_like_type:)
    attr = :volpiano
    value = volpiano

    case music_search_type
    when 'pitches'
      attr = :pitch_series
      value = VolpianoDerivates.pitch_series volpiano
    when 'intervals'
      attr = :interval_series
      value = VolpianoDerivates.snippet_interval_series volpiano
    when 'neume'
      value = "-#{value}-"
    end

    self.where("#{attr} LIKE ?", SearchUtils.like_search_string(value, volpiano_like_type))
  end

  def self.filtered_by_ambitus(min_note, max_note, match_type: :==, transpositions: false)
    if transpositions
      interval = VolpianoDerivates.ambitus("1---#{min_note}#{max_note}---")
      operator = {:== => :eq, :>= => :gteq, :<= => :lteq}.fetch(match_type)
      return self.where(arel_table[:ambitus_interval].public_send(operator, interval))
    end

    case match_type
    when :==
      self.where(ambitus_min_note: min_note, ambitus_max_note: max_note)
    when :>=
      self.where('ambitus_min_note <= ? AND ambitus_max_note >= ?', min_note, max_note)
    when :<=
      self.where('ambitus_min_note >= ? AND ambitus_max_note <= ?', min_note, max_note)
    else
      raise "unexpected match_type #{match_type.inspect}"
    end
  end

  def self.filtered(filter)
    r =
      Chant
        .where(filter.simple_where_attributes)
        .includes(:mismatches, :source_language, :corpus)

    if filter.lyrics.present?
      r = r.filtered_by_lyrics(filter.lyrics, **filter.to_h.slice(:case_sensitive, :normalized, :lyrics_like_type))
    end

    if filter.volpiano.present?
      r = r.filtered_by_melody(filter.volpiano, **filter.to_h.slice(:music_search_type, :volpiano_like_type))
    end

    if filter.ambitus_notes.present?
      r = r.filtered_by_ambitus(
        filter.ambitus_min_note,
        filter.ambitus_max_note,
        match_type: filter.ambitus_search_type,
        transpositions: filter.ambitus_transpositions
      )
    end

    r = r.to_be_fixed if filter.quality_notice
    r = r.favourite if filter.favourite
    r = r.joins(:mismatches) if filter.mismatch
    r = r.where('textus_approbatus IS NOT NULL') if filter.lyrics_edited
    r = r.have_fons_externus if filter.fons_externus
    r = r.obsolete if filter.obsolete

    # TODO: simplify
    r = r.where(id: filter.ids.split(',').collect(&:to_i)) if filter.ids

    if filter.source_file_path.present?
      r =
        r
          .where(source_file_path: filter.source_file_path)
          .order(:source_file_position)
    end

    r
  end

  def parental_tree_top(seen = [])
    raise "cycle in tree of parents #{seen.collect(&:fial_of_self)}" if seen.include? self

    parent.nil? ? self : parent.parental_tree_top(seen + [self])
  end

  # #children_tree_size contains the same value persisted (rather than computed on the fly),
  # but is only available on top parents
  def parental_tree_size
    1 + parental_tree_top.posterity.size
  end

  def has_related_chants?
    parent.present? || children.present?
  end

  # returns a flat Array of all levels of children
  def posterity
    children.flat_map {|c| [c] + c.posterity }
  end

  # returns a flat Array of all levels of relatives
  def relatives
    t = parental_tree_top
    [t] + t.posterity
  end

  def link_text
    lyrics.present? ? lyrics : fial_of_self
  end

  def fial_of_self(scheme: false)
    (scheme ? 'fial://' : '') +
      "#{source_file_path}##{chant_id}"
  end

  def marked_for_revision?
    placet.present? && !placet.start_with?('*')
  end

  def lyrics_edited?
    textus_approbatus.present?
  end

  def lyv_score
    Lyv::LilyPondScore.new(source_code)
  end

  def delete_volpiano!
    VOLPIANO_PROPERTIES.each do |prop|
      public_send "#{prop}=", nil
    end
  end
end
