class Chant < ApplicationRecord
  belongs_to :book
  belongs_to :cycle
  belongs_to :season, optional: true
  belongs_to :corpus
  belongs_to :source_language
  belongs_to :genre
  belongs_to :hour, optional: true
  belongs_to :parent, class_name: 'Chant', optional: true
  has_many :children, class_name: 'Chant', foreign_key: 'parent_id'
  has_many :mismatches, class_name: 'ParentChildMismatch', foreign_key: 'child_id'

  scope :to_be_fixed, -> { where.not(placet: [nil, '*']) }
  scope :favourite, -> { where("placet LIKE '*%'") }
  scope :unique, -> { where(simple_copy: false, copy: false) }
  scope :copies_first, -> do
    order(Arel.sql('CASE
      WHEN simple_copy IS TRUE THEN 1
      WHEN copy IS TRUE THEN 2
      ELSE 3 END'))
  end

  # TODO: instead of hard equality condition really just prefer in ordering
  scope :prefer_same_genre, ->(genre) { where(genre: genre) }

  scope :all_antiphons, -> { joins("INNER JOIN genres ON chants.genre_id = genres.id AND system_name LIKE 'antiphon%'") }

  def self.genres
    distinct.pluck(:quid).compact.sort
  end

  # @return Hash<String => Array<Chant>>
  #   the Chant instances have populated only properties modus, differentia and (ad hoc property) record_count
  def self.modi_and_differentiae
    select(:modus, :differentia, 'count(id) as record_count')
      .group(:modus, :differentia)
      .order(:modus, :differentia)
      .group_by(&:modus)
  end

  def self.similar_by_structure_to(chant, limit=5)
    prefer_same_genre(chant.genre)
      .where.not(id: chant.id)
      .where(melody_section_count: chant.melody_section_count)
      .limit(limit)
  end

  def self.similar_by_lyrics_length_to(chant, limit=5)
    t = arel_table

    prefer_same_genre(chant.genre)
      .where.not(id: chant.id)
      .where(
        t[:word_count].eq(chant.word_count)
          .or(t[:syllable_count].eq(chant.syllable_count))
      )
      .limit(limit)
  end

  def self.required_psalm_tunes
    r = {}

    grp = lambda do |query|
      query
        .select(:modus, :differentia, 'count(chants.id) as record_count')
        .group(:modus, :differentia)
        .order(:modus, :differentia)
    end

    [
      'Zj 19',
      '1 Tim 3'
    ].each do |canticle|
      r[canticle] = grp.(where("psalmus ILIKE '#{canticle}%'"))
      # TODO invitatory
    end

    r['Venite'] = grp.(joins(:genre).where(genre: {system_name: 'invitatory'}))

    r
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

  def parental_tree_top(seen = [])
    raise "cycle in tree of parents #{seen.collect(&:fial_of_self)}" if seen.include? self

    parent.nil? ? self : parent.parental_tree_top(seen + [self])
  end

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

  def link_text
    lyrics.present? ? lyrics : fial_of_self
  end

  def fial_of_self
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
end
