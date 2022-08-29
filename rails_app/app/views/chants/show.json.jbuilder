json.(
  @chant,
  :id,
  :lyrics,
  :textus_approbatus,
  :header,
  :fial_of_self,
  :volpiano,
  :source_code,
  :parent_id
)

%i[book cycle season corpus source_language].each do |relation|
  json.set!(relation, @chant.public_send(relation), :id, :name)
end
