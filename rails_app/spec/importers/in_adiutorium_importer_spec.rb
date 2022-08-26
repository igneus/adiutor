# coding: utf-8
RSpec.describe InAdiutoriumImporter do
  let(:subject) { described_class.new nil }

  describe '#detect_hour' do
    {
      nil => [
        ['invit', 'ANY'],
        ['PREFIX-invit', 'ANY'],
      ],
      :readings => [
        ['mc-a1', 'ANY'],
        ['mc-ant1', 'ANY'],
        ['cte-ant1', 'ANY'],
        ['PREFIX-mc-a1', 'ANY'],
        ['PREFIX-mc-ant1', 'ANY'],
        ['PREFIX-cte-a1', 'ANY'],
      ],
      :lauds => [
        ['rch-a1', 'ANY'],
        ['PREFIX-rch-a1', 'ANY'],
        ['rch-r', 'ANY'],
        ['aben', 'ANY'],
        ['PREFIX-aben', 'ANY'],
        ['PREFIX-ben', 'ANY'],
        ['2aben', 'ANY'],
        ['iiben', 'ANY'],
        ['predvanocni-zlm-po-a1', 'ANY'], # these antiphons are, in fact, used for both Lauds and Vespers, but it's OK to assign them to Lauds alone here
        ['prefix-aben1', 'ANY'],
      ],
      :daytime => [
        ['tercie', 'ANY'],
        ['sexta', 'ANY'],
        ['nona', 'ANY'],
        ['prima', 'ANY'],
        ['up-dopo', 'ANY'],
        ['up-tercie', 'ANY'],
        ['dopo', 'ANY'],
        ['po', 'ANY'],
        ['odpo', 'ANY'],
        ['PREFIX-tercie', 'ANY'],
        ['PREFIX-up-dopo', 'ANY'],
      ],
      :vespers => [
        ['ne-a1', 'ANY'],
        ['PREFIX-ne-a1', 'ANY'],
        ['ne-r', 'ANY'],
        ['1ne-a1', 'ANY'],
        ['2ne-a1', 'ANY'],
        ['PREFIX-1ne-a1', 'ANY'],
        ['amag', 'ANY'],
        ['iimag', 'ANY'],
        ['vmagii', 'ANY'],
        ['PREFIX-amag', 'ANY'],
        ['PREFIX-amag1', 'ANY'],
        ['PREFIX-amag2', 'ANY'],
        ['PREFIX-amag3', 'ANY'],
        ['PREFIX-mag', 'ANY'],
        ['predvanocni-17-o', 'ANY'],
        ['ANY', 'antifony/velikonoce_knzkantikum.ly'],
      ],
      :compline => [
        ['ANY', 'kompletar.ly'],
        ['nei', 'kompletar.ly'],
        ['neii', 'kompletar.ly'],
        ['po', 'kompletar.ly'],
      ],
      nil => [
        ['zacatek-nedele', 'zakladni_napevy.ly']
      ]
    }.each_pair do |expected, examples|
      examples.each do |args|
        it args do
          expect(subject.detect_hour(*args))
            .to eq expected
        end
      end
    end
  end

  describe '#detect_genre' do
    {
      :invitatory => [
        ['invit', 'ANY', 'ANY', :any],
        ['invit2', 'ANY', 'ANY', :any],
        ['PREFIX-invit', 'ANY', 'ANY', :any],
      ],
      :antiphon_psalter => [
        ['ANY', 'ANY', 'kompletar.ly', :any],
        ['ANY', 'ANY', 'antifony/tyden1_1nedele.ly', :any],
        ['ANY', 'ANY', 'antifony/ferie_kantevgant.ly', :any],
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
    }.each_pair do |expected, examples|
      examples.each do |args|
        it args do
          expect(subject.detect_genre(*args))
            .to eq expected
        end
      end
    end
  end
end
