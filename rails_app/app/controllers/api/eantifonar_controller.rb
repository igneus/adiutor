# Prototype of an API for the next version of eantifonar / E-Antiphonal
class Api::EantifonarController < ApplicationController
  skip_before_action :verify_authenticity_token

  def search
    normalizer = LyricsNormalizer.new

    @results =
      request
        .request_parameters
        .reject {|key| key == 'eantifonar' } # system key; we only want keys from the actual POST body
        .collect do |key, val|
      chant_params =
        ActionController::Parameters.new(val)
          .permit(:lyrics, :lang)
          .yield_self do |p|
        method = {
          'cs' => :normalize_czech,
          'la' => :normalize_latin
        }[p[:lang]]
        {lyrics_normalized: normalizer.public_send(method, p[:lyrics])}
      end
      chants = Chant.where(chant_params).limit(10)
      logger.warn "eantifonar API: chant not found for #{chant_params.to_h.inspect}" if chants.empty?
      [key, chants]
    end.to_h

    render formats: :json
  end
end
