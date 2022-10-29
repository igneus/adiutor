# For texts which require special through-composed psalm tones
# finds which tones are required (there are antiphons requiring them)
# and which are available.
class SpecialPsalmTones
  Config = Struct.new(:chants_query_method, :psalm_tone_source_files)

  RequiredTone = Struct.new(:modus, :differentia, :record_count, :available?)

  TEXTS = {
    'Zj 19' => Config.new(:psalmus_query, %w(kantikum-Zj19.ly kantikum-Zj19_kosate.ly)),
    '1 Tim 3' => Config.new(:psalmus_query, %w(kantikum-1Tim3.ly)),
    'Venite' => Config.new(:invitatory_query, %w(invitatoria/zalm95_%.ly))
  }

  def self.call
    new.call
  end

  def call
    TEXTS.each_pair.inject({}) do |result, (canticle, config)|
      query = send(config.chants_query_method, canticle)
      result[canticle] = grp(query, config.psalm_tone_source_files)
      result
    end
  end

  private

  def chants
    @chants ||=
      Corpus
        .find_by_system_name('in_adiutorium')
        .chants
  end

  # Find chants by value of the 'psalmus' header field
  def psalmus_query(bible_ref)
    chants.where("psalmus ILIKE '#{bible_ref}%'")
  end

  # Find invitatory antiphons
  def invitatory_query(_)
    chants.joins("INNER JOIN genres ON chants.genre_id = genres.id AND genres.system_name = 'invitatory'")
  end

  def grp(query, source_files)
    modes_available = source_files.flat_map do |file|
      chants
        .distinct
        .select(:modus)
        .where('source_file_path LIKE ?', file)
        .pluck(:modus)
    end

    query
      .select(:modus, :differentia, 'COUNT(chants.id) AS record_count')
      .group(:modus, :differentia)
      .order(:modus, :differentia)
      .collect do |i|
      RequiredTone.new(
        i.modus,
        i.differentia,
        i.record_count,
        # for now we ignore differentiae in the availability check -
        # the special tones usually don't differentiate
        modes_available.include?(i.modus)
      )
    end
  end
end
