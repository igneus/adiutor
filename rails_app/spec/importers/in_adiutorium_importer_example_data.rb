# coding: utf-8
module InAdiutoriumImporterExampleData
  DETECT_GENRE_EXAMPLES = {
    :invitatory => [
      ['invit', 'ANY', 'ANY'],
      ['invit2', 'ANY', 'ANY'],
      ['PREFIX-invit', 'ANY', 'ANY'],
    ],
    :antiphon_psalter => [
      ['ANY', 'ANY', 'kompletar.ly'],
      ['ANY', 'ANY', 'antifony/tyden1_1nedele.ly'],
      ['ANY', 'ANY', 'antifony/ferie_kantevgant.ly'], # TODO this never happens in the real world, the antiphons (correctly) end up as :antiphon_gospel
      ['ANY', 'ANY', 'antifony/doplnovaci.ly'],
      ['ANY', '1. ant.', 'antifony/tyden1_1nedele.ly'],
    ],
    :antiphon => [
      ['ANY', '1. ant.', 'ANY'],
      ['ANY', 'ant.', 'ANY'],
      ['PREFIX-resp', 'ant. místo responsoria', 'pust_triduum.ly'],

      # While it could be argued that the Eastertide Psalter antiphons are
      # "Psalter antiphons" functionally,
      # their form and content mostly does not fit the genre of Psalter antiphons
      # at all, so we don't consider them as belonging to the genre,
      # but as proper antiphons from the Proper of Seasons.
      ['ANY', '1. ant.', 'antifony/velikonoce_tyden1_2pondeli.ly'],
      ['ANY', '1. ant.', 'antifony/velikonoce_knzkantikum.ly'],
    ],
    :antiphon_gospel => [
      ['ANY', 'ant. k Benedictus', 'ANY'],
      ['ANY', 'ant. k Magnificat', 'ANY'],
      ['ANY', 'ANY', 'antifony/mezidobi_nedeleA_02_10.ly'],

      # antiphons for commemorations of saints in Lent don't have the usual "quid" field,
      # as no Gospel canticle is sung with them, but they clearly belong here genre-wise
      ['aben', 'ant.', 'ANY'],
      ['amag', 'ant.', 'ANY'],
    ],
    :antiphon_standalone => [
      ['ANY', 'ANY', 'marianske_antifony.ly'],
    ],
    :responsory_short => [
      ['ANY', 'resp.', 'ANY'],
    ],
    :responsory_nocturnal => [
      ['ANY', '1. resp.', 'ANY'],
    ]
  }.freeze

  def self.detect_genre_argument_sets
    DETECT_GENRE_EXAMPLES
      .each_value
      .flat_map(&:itself)
  end
end
