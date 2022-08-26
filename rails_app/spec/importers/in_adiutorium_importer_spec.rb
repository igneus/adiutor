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

  describe '#detect_genre'
end
