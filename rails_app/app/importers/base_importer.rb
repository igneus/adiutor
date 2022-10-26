class BaseImporter
  def initialize(corpus)
    @corpus = corpus
  end

  attr_reader :corpus

  def report_unseen_chants
    unseen = corpus.chants_unseen_by_last_import
    return if unseen.empty?

    puts "#{unseen.count} previously imported chants not touched by this import"

    if unseen.count < 50
      unseen.each do |i|
        puts "- ##{i.id} #{i.lyrics}"
      end
    end
  end
end
