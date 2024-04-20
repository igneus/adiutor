# Prototype of an API for the next version of eantifonar / E-Antiphonal
# https://github.com/igneus/eantifonar2
class Api::EantifonarController < ApplicationController
  skip_before_action :verify_authenticity_token

  LanguageConfig = Struct.new :normalizer_method, :alleluia
  LANGUAGES = {
    'cs' => LanguageConfig.new(:normalize_czech, 'aleluja'),
    'la' => LanguageConfig.new(:normalize_latin, 'alleluia'),
  }.freeze

  ENTRY_SCHEMA = Types::Hash.schema(
    lyrics: Types::Coercible::String,
    lang: Types::Coercible::String
  ).with_key_transform(&:to_sym)

  def search
    normalizer = LyricsNormalizer.new
    t = Chant.arel_table

    @results =
      request
        .request_parameters
        .reject {|key| key == 'eantifonar' } # system key; we only want keys from the actual POST body
        .collect do |key, val|
      begin
        chant_params = ENTRY_SCHEMA[val]
        chant_params in {lyrics: lyrics, lang: lang}
        config = LANGUAGES[lang] || raise("unknown language code #{lang}")
      rescue => e
        render status: 400, json: {error: "#{key}: #{e.message}"}
        return
      end

      normalized_lyrics = normalizer.public_send(config.normalizer_method, lyrics)

      query = t[:lyrics_normalized].eq(normalized_lyrics)
        .yield_self do |cond|
        if normalized_lyrics.end_with?(config.alleluia)
          cond
        else
          cond.or(
            t[:alleluia_optional].eq(true)
              .and(t[:lyrics_normalized].eq(normalized_lyrics + ' ' + config.alleluia))
          )
        end
      end
      chants = Chant.where(query).limit(10)
      logger.warn "eantifonar API: chant not found for #{chant_params.to_h.inspect}" if chants.empty?
      [key, chants]
    end.to_h

    render formats: :json
  end
end
