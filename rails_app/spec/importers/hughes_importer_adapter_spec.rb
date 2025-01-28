describe HughesImporter::Adapter do
  let(:xml) do
    '<mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
	<meiHead>
		<fileDesc>
			<titleStmt>
				<title>Zelus</title>
			</titleStmt>
			<pubStmt />
		</fileDesc>
		<extMeta>mode:7###final:g###office:Matins###saint:5=XL.6=x_{MT}###lyrics: zelus domus tue comedit me et opprobria exprobrancium tibi ceciderunt super me ###</extMeta>
		<extMeta />
		<extMeta />
	</meiHead>
	<music>
		<body>
			<mdiv>
				<score>
					<scoreDef>
						<staffGrp>
							<staffDef clef.line="2" clef.shape="G" lines="5" n="1" />
						</staffGrp>
					</scoreDef>
					<section>
						<measure right="invis">
							<staff n="1">
								<layer>
									<note pname="c" oct="5" dur="4" stem.dir="up" stem.len="0">
										<verse n="1">
											<syl>Ze-</syl>
										</verse>
									</note>
</layer></staff></measure></section></score></mdiv></body></music></mei>'
  end

  let(:txt) do
    <<EOS
        |g21=MA1.1d

/ celitus acta dieS illustret festa colenteS festa quibus sanctuS celos peciit adalarduS /()

\ celitus.13.0.1 acta.14.43 dieS.4313.21; illustret.14.43454.21 festa.01343.21 colenteS.231.01.1; festa.5==43'45.5 quibus.54.45 ^ sanctuS.57.865'7654; celos.543.454 peciit.567.65.5 adalarduS.32.10.1231.1; \()

\. .1301,3 .1443,2 .431321,2 .144345421,3 .0134321,2 .231011,3 .543455,2 .5445,2 .578657654,2 .543454,2 .567655,3 .321012311,4 .()

\# #865'7654; #sanctuS,2.7 #()

\` 1d 1 301 43431 321 4345421 01 34321 231 01 543454578 65 765 454345456765 321 01 231 `()
EOS
  end

  let(:subject) { described_class.new(xml, 'some/path', txt) }

  describe '#header' do
    it 'contains key-value pairs from the extMeta header elements' do
      expect(subject.header)
        .to include(
              'mode' => '7',
              'final' => 'g',
              'office' => 'Matins',
              'saint' => '5=XL.6=x_{MT}',
            )
    end

    it 'contains information extracted from the txt file' do
      expect(subject.header)
        .to include(
              'txt_meta' => {
                'hour' => 'M',
                'genre' => 'A',
                'position' => '1',
                'mode' => '1d',
              }
            )
    end
  end

  describe '#hour_system_name' do
    it { expect(subject.hour_system_name).to eq 'readings' }
  end

  describe '#genre_system_name' do
    it { expect(subject.genre_system_name).to eq 'antiphon' }
  end

  describe '#modus, #differentia' do
    describe 'available in the data' do
      it { expect(subject.modus).to eq 'VII' }
      it { expect(subject.differentia).to eq 'g' }
    end

    describe 'not available' do
      before :each do
        xml.gsub! /<extMeta>.*?<\/extMeta>/, '<extMeta></extMeta>'
      end

      it { expect(subject.modus).to eq nil }
      it { expect(subject.differentia).to eq nil }
    end

    describe 'empty' do
      before :each do
        xml.gsub! /<extMeta>.*?<\/extMeta>/, '<extMeta>mode:###final:</extMeta>'
      end

      it { expect(subject.modus).to eq nil }
      it { expect(subject.differentia).to eq nil }
    end

    describe 'non-standard' do
      before :each do
        xml.gsub! /<extMeta>.*?<\/extMeta>/, '<extMeta>mode:O###final:s</extMeta>'
      end

      it 'keeps the non-standard value' do
        expect(subject.modus).to eq 'O'
      end

      it { expect(subject.differentia).to eq 's' }
    end
  end
end
