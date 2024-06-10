%w(
fial
lib/checkcopies/child_parent_comparison
lib/updatefromvar/development_files_finder
).each do |l|
  require File.join(Rails.root, 'vendor', 'inadiutorium', l)
end
