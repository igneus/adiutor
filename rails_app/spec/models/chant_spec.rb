RSpec.describe Chant, type: :model do
  let :default_chant_params do
    {
      book: Book.create!,
      cycle: Cycle.create!,
      corpus: Corpus.create!,
      source_language: SourceLanguage.create!,
      genre: Genre.create!
    }
  end

  describe '.to_be_fixed' do
    [
      [nil, false, 'no quality notice means OK'],
      ['some text', true, 'quality notice means fix is necessary'],
      ['* some text', false, 'quality notice which starts with an asterisk means a favourite piece'],
    ].each do |(placet_value, should_be_found, label)|
      it label do
        chant = create :chant, placet: placet_value
        expect(Chant.to_be_fixed)
          .public_send(
            (should_be_found ? :to : :not_to),
            include(chant)
          )
      end
    end
  end

  describe '.obsolete' do
    before :each do
      @corpus = create :corpus
      @last_import = create :import, corpus: @corpus, started_at: 1.hour.ago
      @older_import = create :import, corpus: @corpus, started_at: 2.days.ago
    end

    it 'finds obsolete chant' do
      chant = create :chant, corpus: @corpus, import: @older_import
      expect(Chant.obsolete).to include chant
    end

    it 'does not find chant seen by the last import' do
      chant = create :chant, corpus: @corpus, import: @last_import
      expect(Chant.obsolete).not_to include chant
    end
  end

  describe '.filtered_by_ambitus' do
    before :each do
      @a = create :chant, ambitus_min_note: 'c', ambitus_max_note: 'g', ambitus_interval: 7
    end

    describe 'absolute' do
      describe '==' do
        it 'find' do
          expect(Chant.filtered_by_ambitus('c', 'g'))
            .to include @a
        end

        describe 'miss' do
          {
            'max differs' => ['c', 'k'],
            'min differs' => ['d', 'g'],
            'both differ' => ['f', 'k'],
          }.each_pair do |label, values|
            it label do
              expect(Chant.filtered_by_ambitus(*values))
                .not_to include @a
            end
          end
        end
      end

      describe '>=' do
        let(:match_type) { :>= }

        describe 'find' do
          {
            'exact match' => ['c', 'g'],
            'min exceeds' => ['d', 'g'],
            'max exceeds' => ['c', 'f'],
            'both exceed' => ['d', 'f'],
          }.each_pair do |label, values|
            it label do
              expect(Chant.filtered_by_ambitus(*values, match_type: match_type))
                .to include @a
            end
          end
        end

        describe 'miss' do
          {
            'min within' => ['b', 'g'],
            'max within' => ['c', 'h'],
            'both within' => ['b', 'h'],
          }.each_pair do |label, values|
            it label do
              expect(Chant.filtered_by_ambitus(*values, match_type: match_type))
                .not_to include @a
            end
          end
        end
      end

      describe '<=' do
        let(:match_type) { :<= }

        describe 'find' do
          {
            'exact match' => ['c', 'g'],
            'min within' => ['b', 'g'],
            'max within' => ['c', 'h'],
            'both within' => ['b', 'h'],
          }.each_pair do |label, values|
            it label do
              expect(Chant.filtered_by_ambitus(*values, match_type: match_type))
                .to include @a
            end
          end
        end

        describe 'miss' do
          {
            'min exceeds' => ['d', 'g'],
            'max exceeds' => ['c', 'f'],
            'both exceed' => ['d', 'f'],
          }.each_pair do |label, values|
            it label do
              expect(Chant.filtered_by_ambitus(*values, match_type: match_type))
                .not_to include @a
            end
          end
        end
      end
    end

    describe 'interval' do
      describe '==' do
        describe 'find' do
          [
            ['c', 'g'],
            ['d', 'h'],
            ['e', 'j'],
          ].each do |values|
            it values.inspect do
              expect(Chant.filtered_by_ambitus(*values, transpositions: true))
                .to include @a
            end
          end
        end

        describe 'miss' do
          [
            ['d', 'g'],
            ['d', 'j'],
            ['c', 'h'],
          ].each do |values|
            it values.inspect do
              expect(Chant.filtered_by_ambitus(*values, transpositions: true))
                .not_to include @a
            end
          end
        end
      end

      describe '>=' do
        it 'find' do
          expect(Chant.filtered_by_ambitus('d', 'e', match_type: :>=, transpositions: true))
            .to include @a
        end

        it 'miss' do
          expect(Chant.filtered_by_ambitus('d', 'm', match_type: :>=, transpositions: true))
            .not_to include @a
        end
      end

      describe '<=' do
        it 'find' do
          expect(Chant.filtered_by_ambitus('d', 'm', match_type: :<=, transpositions: true))
            .to include @a
        end

        it 'miss' do
          expect(Chant.filtered_by_ambitus('d', 'e', match_type: :<=, transpositions: true))
            .not_to include @a
        end
      end
    end
  end

  describe '.similar_by_structure_to' do
    it 'does not crash on missing properties' do
      chant = create(:chant, melody_section_count: nil)

      # ActiveRecord seemingly does some kind of preliminary check
      # and if there is no other Chant of the given Genre,
      # `similar_by_structure_to` doesn't fire the SQL query at all
      other_chant = create(:chant, genre: chant.genre)

      similar = described_class.similar_by_structure_to(chant)
      expect(similar).to include other_chant
    end
  end

  describe '.similar_by_lyrics_length_to' do
    it 'does not crash on missing properties' do
      chant = create(:chant, word_count: nil, syllable_count: nil)

      other_chant = create(:chant, genre: chant.genre)

      similar = described_class.similar_by_lyrics_length_to(chant)
      expect(similar).to include other_chant
    end
  end

  describe '.top_parents' do
    it 'does not select an isolated chant' do
      chant = create :chant
      expect(Chant.top_parents).not_to include chant
    end

    it 'selects chant having a child' do
      parent = create :chant
      create :chant, parent: parent

      expect(Chant.top_parents).to include parent
    end

    it 'does not select second level parent' do
      top_parent = create :chant
      parent = create :chant, parent: top_parent
      create :chant, parent: parent

      expect(Chant.top_parents).not_to include parent
    end
  end

  describe '#parental_tree_top' do
    it 'prevents infinite loop' do
      a = Chant.new(**default_chant_params)
      b = Chant.create!(**default_chant_params.merge(parent: a))
      a.update!(parent: b)

      expect { a.parental_tree_top }
        .to raise_exception /cycle in tree of parents/
    end
  end
end
