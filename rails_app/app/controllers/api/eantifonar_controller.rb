# Prototype of an API for the next version of eantifonar / E-Antiphonal
class Api::EantifonarController < ApplicationController
  skip_before_action :verify_authenticity_token

  def search
    @results =
      request
        .request_parameters
        .reject {|key| key == 'eantifonar' } # system key; we only want keys from the actual POST body
        .collect do |key, val|
      chant_params = ActionController::Parameters.new(val).permit(:lyrics)
      [key, Chant.where(chant_params).limit(10)]
    end.to_h

    render formats: :json
  end
end
