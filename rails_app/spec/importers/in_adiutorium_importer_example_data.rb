# coding: utf-8
module InAdiutoriumImporterExampleData
  DETECT_GENRE_EXAMPLES = {
    :invitatory => [
      ['invit', 'ANY', 'ANY', :any],
      ['invit2', 'ANY', 'ANY', :any],
      ['PREFIX-invit', 'ANY', 'ANY', :any],
    ],
    :antiphon_psalter => [
      ['ANY', 'ANY', 'kompletar.ly', :any],
      ['ANY', 'ANY', 'antifony/tyden1_1nedele.ly', :any],
      ['ANY', 'ANY', 'antifony/ferie_kantevgant.ly', :any], # TODO this never happens in the real world, the antiphons (correctly) end up as :antiphon_gospel
      ['ANY', 'ANY', 'antifony/doplnovaci.ly', :any],
      ['ANY', '1. ant.', 'antifony/tyden1_1nedele.ly', :any],
    ],
    :antiphon => [
      ['ANY', '1. ant.', 'ANY', :any],
      ['ANY', 'ant.', 'ANY', :any],
      ['PREFIX-resp', 'ant. místo responsoria', 'pust_triduum.ly', :any],

      # While it could be argued that the Eastertide Psalter antiphons are
      # "Psalter antiphons" functionally,
      # their form and content mostly does not fit the genre of Psalter antiphons
      # at all, so we don't consider them as belonging to the genre,
      # but as proper antiphons from the Proper of Seasons.
      ['ANY', '1. ant.', 'antifony/velikonoce_tyden1_2pondeli.ly', :any],
      ['ANY', '1. ant.', 'antifony/velikonoce_knzkantikum.ly', :any],
    ],
    :antiphon_gospel => [
      ['ANY', 'ant. k Benedictus', 'ANY', :any],
      ['ANY', 'ant. k Magnificat', 'ANY', :any],
      ['ANY', 'ANY', 'antifony/mezidobi_nedeleA_02_10.ly', :any],

      # antiphons for commemorations of saints in Lent don't have the usual "quid" field,
      # as no Gospel canticle is sung with them, but they clearly belong here genre-wise
      ['aben', 'ant.', 'ANY', :any],
      ['amag', 'ant.', 'ANY', :any],
    ],
    :antiphon_standalone => [
      ['ANY', 'ANY', 'marianske_antifony.ly', :any],
    ],
    :responsory_short => [
      ['ANY', 'resp.', 'ANY', :any],
    ],
    :responsory_nocturnal => [
      ['ANY', '1. resp.', 'ANY', :readings],
    ]
  }.freeze

  def self.detect_genre_argument_sets
    DETECT_GENRE_EXAMPLES
      .each_value
      .flat_map(&:itself)
  end
end
