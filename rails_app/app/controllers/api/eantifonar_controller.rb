# Prototype of an API for the next version of eantifonar / E-Antiphonal
class Api::EantifonarController < ApplicationController
  skip_before_action :verify_authenticity_token

  LanguageConfig = Struct.new :normalizer_method, :alleluia
  LANGUAGES = {
    'cs' => LanguageConfig.new(:normalize_czech, 'aleluja'),
    'la' => LanguageConfig.new(:normalize_latin, 'alleluia'),
  }.freeze

  def search
    normalizer = LyricsNormalizer.new
    t = Chant.arel_table

    @results =
      request
        .request_parameters
        .reject {|key| key == 'eantifonar' } # system key; we only want keys from the actual POST body
        .collect do |key, val|
      chant_params =
        ActionController::Parameters.new(val)
          .permit(:lyrics, :lang)
      query = chant_params.yield_self do |p|
        config = LANGUAGES[p[:lang]]
        normalized_lyrics = normalizer.public_send(config.normalizer_method, p[:lyrics])

        t[:lyrics_normalized].eq(normalized_lyrics)
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
      end
      chants = Chant.where(query).limit(10)
      logger.warn "eantifonar API: chant not found for #{chant_params.to_h.inspect}" if chants.empty?
      [key, chants]
    end.to_h

    render formats: :json
  end
end
