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
      a.parent = b
      a.save!

      expect { a.parental_tree_top }
        .to raise_exception /cycle in tree of parents/
    end
  end
end
