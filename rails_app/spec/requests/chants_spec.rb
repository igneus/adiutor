require 'rails_helper'

RSpec.describe 'Chants', type: :request do
  describe 'GET /chants' do
    it 'succeeds' do
      get '/chants'
      expect(response).to have_http_status :ok
    end

    it 'can serve also JSON' do
      get "/chants.json"
      expect(response).to have_http_status :ok
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
      expect(response.body).to eq '[]'
    end
  end

  describe 'GET /chants/:id' do
    it 'succeeds' do
      chant = create :chant, source_code: "%%\n(c4) A(h)men.(h)", corpus: create(:corpus)

      get "/chants/#{chant.id}"
      expect(response).to have_http_status :ok
    end

    it 'can serve also JSON' do
      chant = create(
        :chant,
        source_code: "%%\n(c4) A(h)men.(h)",
        book: create(:book),
        cycle: create(:cycle),
        season: create(:season),
        corpus: create(:corpus),
        source_language: create(:source_language)
      )

      get "/chants/#{chant.id}.json"
      expect(response).to have_http_status :ok
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
      expect(response.body).to start_with '{"id":'
      expect(response.body).to end_with '}'
      expect(response.body).to end_with '}'
      expect(response.body).to include ',"volpiano":null,'
    end
  end

  describe 'GET /chants/resp-atyp' do
    it 'succeeds' do
      get '/chants/resp-atyp'
      expect(response).to have_http_status :ok
      expect(response.body).to include 'Atypical Responsories'
    end
  end
end
