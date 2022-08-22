class BaseImporter
  def initialize(corpus)
    @corpus = corpus
  end

  attr_reader :corpus
end
