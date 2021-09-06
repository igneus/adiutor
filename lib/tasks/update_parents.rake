desc 'for each score translate fial to a relation to a parent record'
task update_parents: [:environment] do
  Chant.where.not(fial: nil).find_each do |chant|
    fial = FIAL.parse(chant.fial)
    parent = Chant.find_by(source_file_path: fial.path, chant_id: fial.id)
    puts "parent not found for ##{chant.id} - #{chant.fial_of_self}" if parent.nil?

    chant.update! parent: parent
  end
end

desc 'checks if each score matchis its parent'
task compare_parents: [:environment] do
  ParentChildMismatch.delete_all

  Chant.where.not(parent: nil).find_each do |chant|
    comparison = ChildParentComparison.new chant.lyv_score, chant.parent.lyv_score
    unless comparison.match?
      ParentChildMismatch.create!(child: chant)
    end
  end
end
