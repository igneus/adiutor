# code loaded from the In-adiutorium source tree
%w(
fial
lib/checkcopies/child_parent_comparison
).each do |l|
  require File.join(Adiutor::IN_ADIUTORIUM_SOURCES_PATH, 'nastroje', l)
end
