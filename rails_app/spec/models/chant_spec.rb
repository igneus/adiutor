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
