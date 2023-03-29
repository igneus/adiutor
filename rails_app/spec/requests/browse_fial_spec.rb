require 'rails_helper'

RSpec.describe 'Browse FIAL', type: :request do
  describe 'POST /chants/fial' do
    it 'redirects to a listing containing the specified chants' do
      chant1 = create(
        :chant,
        source_file_path: 'basename.ly',
        chant_id: 'chant1id'
      )
      chant2 = create(
        :chant,
        source_file_path: 'basename.ly',
        chant_id: 'chant2id'
      )

      # this is how raw POST body is sent with rspec-rails request specs
      body = [chant1, chant2].collect(&:fial_of_self).join("\n")
      post '/chants/fial', headers: {'RAW_POST_DATA' => body}

      expect(response).to have_http_status 302
      expect(response.headers['Location']).to include "ids=#{chant1.id}%2C#{chant2.id}"
    end
  end

  describe 'GET /chants/fial/:fial' do
    it 'root directory' do
      chant = create(
        :chant,
        source_file_path: 'basename.ly',
        chant_id: 'chantid'
      )

      get '/chants/fial/basename.ly%23chantid'
      expect(response).to redirect_to "/chants/#{chant.id}"
    end

    it 'subdirectory' do
      chant = create(
        :chant,
        source_file_path: 'subdirectory/basename.ly',
        chant_id: 'chantid'
      )

      get '/chants/fial/subdirectory%2Fbasename.ly%23chantid'
      expect(response).to redirect_to "/chants/#{chant.id}"
    end
  end
end
