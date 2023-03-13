# coding: utf-8
describe DivinumOfficium::Formulary do
  let(:subject) { described_class.new source }

  describe '#items' do
    describe 'empty file' do
      let(:source) { '' }

      it 'is empty' do
        expect(subject.items).to eq []
      end
    end

    describe 'empty section with no text' do
      let(:source) { "[Title]\n\n\n\n" }

      it 'is empty' do
        expect(subject.items).to eq []
      end
    end

    describe 'one item' do
      let(:source) { "[Title]\nContents" }

      it 'is available' do
        expect(subject.items.size).to be 1

        i = subject.items[0]
        expect(i.title).to eq 'Title'
        expect(i.text).to eq 'Contents'
        expect(i.section_pos).to be nil
      end
    end

    describe 'two items' do
      let(:source) { "[Title]\nContents\n\n[Another]\nMore contents" }

      it 'is available' do
        expect(subject.items.size).to be 2

        i = subject.items[0]
        expect(i.title).to eq 'Title'
        expect(i.text).to eq 'Contents'

        i = subject.items[1]
        expect(i.title).to eq 'Another'
        expect(i.text).to eq 'More contents'
      end
    end

    describe 'attached numbers' do
      [
        ';;93',
        ';;269;270;271',
      ].each do |numbers|
        describe numbers do
          let(:source) { "[Title]\nContents" + numbers }
          it 'ignores them' do
            expect(subject.items.size).to be 1

            i = subject.items[0]
            expect(i.title).to eq 'Title'
            expect(i.text).to eq 'Contents'
          end
        end
      end

      describe 'on a line of their own' do
        [
          ['one', ";;8"],
          ['multiple', ";;8\n;;93\n;;94"],
        ].each do |label, numbers|
          describe label do
            let(:source) { "[Ant Matutinum]\n#{numbers}" }

            it 'ignores them' do
              expect(subject.items).to be_empty
            end
          end
        end
      end
    end

    describe 'versicle immediately following antiphon text' do
      let(:source) do
        <<EOS
[Ant Matutinum 3N]
Miserére mei, Fili David! † Quid vis ut fáciam tibi? Dómine, ut vídeam.
V. Exaltáre Dómine in virtúte tua.
R. Cantábimus et psallémus virtútes tuas.
EOS
      end

      it 'parses the versicle as a separate item' do
        expect(subject.items.size).to be 2

        antiphon, versicle = subject.items
        expect(versicle.title).to eq 'Ant Matutinum 3N'
        expect(versicle.text).to match /\AV\. Exaltáre.+?tuas.\Z/m
        expect(versicle.section_pos).to eq 2

        expect(antiphon.section_pos).to eq 1
      end
    end

    describe 'responsory' do
      let(:source) do
        <<EOS
[Responsory8]
R. Visitávit Dóminus Saram, sicut promíserat et implévit quæ locútus est: † concepítque et péperit fílium in senectúte sua
* Témpore quo prædíxerat ei Deus.
V. Vocavítque Abraham nomen fílii sui quem génuit ei Sara, Isaac.
R. Témpore quo prædíxerat ei Deus.
EOS
      end

      it 'does not break it' do
        expect(subject.items.size).to be 1

        resp = subject.items.first
        expect(resp.title).to eq 'Responsory8'
        expect(resp.text).to match /\AR\. Visitávit.+?^R\. Témpore.+?Deus.\Z/m
      end
    end

    describe 'multiple antiphons under the same title' do
      let(:source) do
        <<EOS
[Ant Laudes]
Secúndum multitúdinem * miseratiónum tuárum, Dómine, dele iniquitátem meam.
Deus meus es tu, * et confitébor tibi: Deus meus es tu, et exaltábo te.
Ad te de luce * vígilo, Deus, ut vídeam virtútem tuam.
Hymnum dícite, * et superexaltáte eum in sǽcula.
Omnes Angeli * ejus laudáte Dóminum de cælis.
EOS
      end

      it 'parses them as separate items' do
        expect(subject.items.size).to be 5
        expect(subject.antiphons.size).to be 5

        a1 = subject.items[0]
        expect(a1.title).to eq 'Ant Laudes'
        expect(a1.text).to eq 'Secúndum multitúdinem * miseratiónum tuárum, Dómine, dele iniquitátem meam.'
        expect(a1.section_pos).to be 1

        a5 = subject.items[4]
        expect(a5.title).to eq 'Ant Laudes'
        expect(a5.text).to eq 'Omnes Angeli * ejus laudáte Dóminum de cælis.'
        expect(a5.section_pos).to be 5
      end
    end
  end

  describe '#antiphons' do
    describe 'non-antiphon' do
      let(:source) { "[Lectio Prima]\nlesson content" }

      it 'is not found' do
        expect(subject.antiphons).to be_empty
      end
    end

    describe 'antiphon' do
      let(:source) { "[Ant 2]\nantiphon content" }

      it 'is found' do
        expect(subject.antiphons).not_to be_empty
      end
    end

    describe 'versicle with an antiphon-like title' do
      let(:source) do
        <<EOS
[Ant Matutinum 3N]
Miserére mei, Fili David! † Quid vis ut fáciam tibi? Dómine, ut vídeam.
V. Exaltáre Dómine in virtúte tua.
R. Cantábimus et psallémus virtútes tuas.
EOS
      end

      it 'is found' do
        expect(subject.antiphons.size).to be 1
        expect(subject.antiphons.first.text).to end_with 'ut vídeam.'
      end
    end
  end
end
