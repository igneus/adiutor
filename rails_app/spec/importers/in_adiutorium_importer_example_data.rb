# coding: utf-8
module InAdiutoriumImporterExampleData
  DETECT_GENRE_EXAMPLES = {
    :invitatory => [
      ['invit', 'ant.', 'mezidobi_trojice.ly'],
      ['invit2', 'ant.', 'pust_antifony.ly'],
      ['vden-invit', 'ant.', 'vanoce_narozenipane.ly'],
      ['spol-invit3', 'ant.', 'advent_antifony.ly'],
      ['t1po', 'ant.', 'antifony/invitatoria.ly'], # invitatories from the Psalter are not considered Psalter antiphons genre-wise
    ],
    :antiphon_psalter => [
      ['po', 'pondělí - ant.', 'kompletar.ly'],
      ['1ne-ant1', '1. ant.', 'antifony/tyden1_1nedele.ly'],
      ['tercie-ant1', '1. ant.', 'antifony/doplnovaci.ly'],
    ],
    :antiphon => [
      ['1ne-a1', '1. ant.', 'mezidobi_trojice.ly'],
      ['ct-resp', 'ant. místo responsoria', 'pust_triduum.ly'],

      # While it could be argued that the Eastertide Psalter antiphons are
      # "Psalter antiphons" functionally,
      # their form and content mostly does not fit the genre of Psalter antiphons
      # at all, so we don't consider them as belonging to the genre,
      # but as proper antiphons from the Proper of Seasons.
      ['rch-a1', '1. ant.', 'antifony/velikonoce_tyden1_2pondeli.ly'],
      ['t1-po', '3. ant.', 'antifony/velikonoce_knzkantikum.ly'],

      # (This one is imported as antiphon_standalone, but that's governed
      # by the adiutor_genre header, #detect_genre detects it
      # as general antiphon.)
      ['chresurgens', 'ant.', 'paraliturgicke/velikonoce_pruvod.ly'],
    ],
    :antiphon_gospel => [
      ['rch-aben', 'ant. k Benedictus', 'mezidobi_trojice.ly'],
      ['1ne-amag', 'ant. k Magnificat', 'mezidobi_trojice.ly'],
      ['ne2a-1ne-amag', 'ant. k Magnificat', 'antifony/mezidobi_nedeleA_02_10.ly'],
      ['t1-po-ben', 'ant. k Benedictus', 'antifony/ferie_kantevgant.ly'], # Gospel antiphons from the Psalter are not considered Psalter antiphons genre-wise

      # antiphons for commemorations of saints in Lent don't have the usual "quid" value,
      # as no Gospel canticle is sung with them, but they clearly belong here genre-wise
      ['aben', 'ant.', 'sanktoral/0317patrik.ly'],
      ['amag', 'ant.', 'sanktoral/0317patrik.ly'],
    ],
    :antiphon_standalone => [
      ['alma', 'ant.', 'marianske_antifony.ly'],
    ],
    :responsory_short => [
      ['rch-resp', 'resp.', 'sanktoral/0815nanebevzetipm.ly'],
      ['rch-r', 'resp.', 'sanktoral/0118pmmatkyjednoty.ly'],
      ['resp', 'resp.', 'kompletar.ly'],
    ],
    :responsory_nocturnal => [
      ['mc-r1', '1. resp.', 'sanktoral/0815nanebevzetipm.ly'],
    ]
  }.freeze

  def self.detect_genre_argument_sets
    DETECT_GENRE_EXAMPLES
      .each_value
      .flat_map(&:itself)
  end
end
