require 'rails_helper'

RSpec.describe 'Chants', type: :request do
  describe 'GET /chants' do
    it 'succeeds' do
      get '/chants'
      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /chants/:id' do
    it 'succeeds' do
      chant = create :chant, source_code: "%%\n(c4) A(h)men.(h)"

      get "/chants/#{chant.id}"
      expect(response).to have_http_status :ok
    end
  end
end
