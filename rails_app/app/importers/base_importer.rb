class BaseImporter
  # Chant#chant_id value used for corpora which have only a single chant per source file
  # (like gabc-based corpora)
  DEFAULT_CHANT_ID = '1'

  def initialize(corpus)
    @corpus = corpus
  end

  attr_reader :corpus

  # template method orchestrating the most usual import workflow
  def call(corpus_path)
    common_attributes = build_common_attributes

    corpus.imports.build.do! do |import|
      do_import(
        common_attributes.merge(
          corpus: corpus,
          import: import
        ),
        corpus_path
      )
    end

    report_unseen_chants
    report_unimplemented_attributes(common_attributes.keys)
  end

  # returns valid argument to `Chant#assign_attributes`
  # containing attribute values valid for all imported records.
  def build_common_attributes
    {}
  end

  def do_import(common_attributes, corpus_path)
    raise 'not implemented'
  end

  def update_chant_from_adapter(chant, adapter)
    BaseImportDataAdapter.attributes.each do |a|
      chant.public_send("#{a}=", adapter.send(a))
    end
  end

  # for the transition to Adapters:
  # 1. run import as so far, but additionally build Adapter for each chant and compare contents
  # 2. when Adapter generates the same data as the import so far, switch to the method above
  #    and delete old code from the Importer
  #
  # TODO delete once the transition is completed
  def compare_chant_with_adapter(chant, adapter)
    BaseImportDataAdapter.attributes.each do |a|
      av = adapter.public_send(a)
      cv = chant.public_send(a)
      if av != cv
        puts "!!! #{a}: #{av.inspect} _x_ #{cv.inspect}"
      end
    end
  end

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

  def report_unimplemented_attributes(additional_implemented=[])
    puts "Chant attributes not implemented/populated by this importer:"
    p(self.class::Adapter.unimplemented_attributes - additional_implemented)
  end
end
