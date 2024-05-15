describe LiturgiaHorarumLinkBuilder do
  shared_context 'unsupported piece' do
    let(:chant) { double(Chant, source_file_path: 'unknown.ly') }
  end

  describe '#call' do
    describe 'unsupported piece' do
      include_context 'unsupported piece'

      it 'returns nil' do
        expect(subject.call(chant)).to be nil
      end
    end

    it 'generates a URL' do
      chant = Chant.new(
        source_file_path: 'sanktoral/0103jmenajezis.ly',
        chant_id: 'amag',
        hour: Hour.new(system_name: 'vespers')
      )
      expect(subject.call(chant))
        .to eq 'https://breviar.sk/cgi-bin/l.cgi?qt=pdt&d=3&m=1&r=2000&p=mv&ds=1&j=la&o3=8'
    end
  end

  describe '#date_and_hour' do
    describe 'unsupported piece' do
      include_context 'unsupported piece'

      it 'returns nil' do
        expect(subject.date_and_hour(chant)).to be nil
      end
    end

    [
      # sanctorale
      [
        'sanktoral/0103jmenajezis.ly', 'amag', 'vespers',
        [Date.new(2000, 1, 3), :vespers]
      ],
      [
        'sanktoral/0103jmenajezis.ly', 'aben', 'lauds',
        [Date.new(2000, 1, 3), :lauds]
      ],
      [
        'sanktoral/0599neposkvrnenehosrdcepm.ly', 'aben', 'lauds',
        nil,
        'movable sanctorale feasts unsupported for now'
      ],

      # handling differences between our and breviar.sk Hour ontology:
      # 1. here invitatories have no Hour, over there they "are" an hour
      [
        'sanktoral/0125obracenipavla.ly', 'invit', nil,
        [Date.new(2000, 1, 25), :invitatory]
      ],
      # 2. here there is only one Daytime Prayer (as Hour record),
      #    over there there are three separate hours
      [
        'sanktoral/0125obracenipavla.ly', 'tercie', 'daytime',
        [Date.new(2000, 1, 25), :terce]
      ],
    ].each do |source_file_path, chant_id, hour_name, expected, label|
      it(label || source_file_path) do
        chant = Chant.new(
          source_file_path: source_file_path,
          chant_id: chant_id,
          hour: hour_name&.then {|x| Hour.new(system_name: x) }
        )
        expect(subject.date_and_hour(chant)).to eq expected
      end
    end
  end
end
