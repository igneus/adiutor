desc 'for each score translate fial to a relation to a parent record'
task update_parents: [:environment] do
  Chant.where.not(fial: nil).find_each do |chant|
    fial = FIAL.parse(chant.fial)
    parent = chant.corpus.chants.find_by(source_file_path: fial.path, chant_id: fial.id)
    puts "parent not found for ##{chant.id} - #{chant.fial_of_self}" if parent.nil?

    chant.update! parent: parent
  end
end

desc 'save children tree size for each top parent'
task update_children_tree_size: [:environment] do
  Chant.update_all(children_tree_size: nil)

  Chant.top_parents.each do |chant|
    chant.update(children_tree_size: chant.parental_tree_size)
  end
end

desc 'checks if each score matches its parent'
task compare_parents: [:environment] do
  ParentChildMismatch.delete_all

  Corpus
    .find_by_system_name!('in_adiutorium')
    .chants
    .where.not(parent: nil)
    .find_each do |chant|
    comparison = ChildParentComparison.new chant.lyv_score, chant.parent.lyv_score
    unless comparison.match?
      ParentChildMismatch.create!(child: chant)
    end
  end
end
