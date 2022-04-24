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
    where(melody_section_count: chant.melody_section_count)
      .limit(limit)
  end

  def self.similar_by_lyrics_length_to(chant, limit=5)
    where(word_count: chant.word_count)
      .or(where(syllable_count: chant.syllable_count))
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

  def parental_tree_top(seen = [])
    raise "cycle in tree of parents #{seen.collect(&:fial_of_self)}" if seen.include? self

    parent.nil? ? self : parent.parental_tree_top(seen + [self])
  end

  def link_text
    lyrics.present? ? lyrics : fial_of_self
  end

  def fial_of_self
    "#{source_file_path}##{chant_id}"
  end

  def marked_for_revision?
    placet.present? && placet != '*'
  end

  def lyrics_edited?
    textus_approbatus.present?
  end

  def lyv_score
    Lyv::LilyPondScore.new(source_code)
  end
end
