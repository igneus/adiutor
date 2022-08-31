@results.each_pair do |key, val|
  result =
    if val.empty?
      nil
    else
      val.collect do |chant|
        {
          id: chant.id,
          modus: chant.modus,
          differentia: chant.differentia,
          genre: chant.genre.system_name,
          lyrics: chant.lyrics,
          image: image_url("chants/#{chant.source_language.system_name}/#{chant.id}.svg")
        }
      end
    end

  json.set! key, result
end
