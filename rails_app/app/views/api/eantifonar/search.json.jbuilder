@results.each_pair do |key, val|
  result =
    if val.empty?
      nil
    else
      val.collect do |chant|
        {
          id: chant.id,
          browse_url: chant_url(chant), # human-friendly detail of the chant
          modus: chant.modus,
          differentia: chant.differentia,
          genre: chant.genre.system_name,
          lyrics: chant.lyrics,
          image:
            begin
              image_url("chants/#{chant.source_language.system_name}/#{chant.id}.svg")
            rescue Sprockets::Rails::Helper::AssetNotFound
              nil
            end
        }
      end
    end

  json.set! key, result
end
