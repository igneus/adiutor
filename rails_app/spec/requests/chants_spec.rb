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
      chant = create :chant, source_code: "%%\n(c4) A(h)men.(h)"

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
      create :in_adiutorium_corpus
      create :genre, system_name: 'responsory_short'

      get '/chants/resp-atyp'
      expect(response).to have_http_status :ok
      expect(response.body).to include 'Atypical Responsories'
    end
  end

  describe 'GET /chants/clusters' do
    it 'succeeds' do
      create :in_adiutorium_corpus

      get '/chants/clusters'
      expect(response).to have_http_status :ok
      expect(response.body).to include 'Clusters'
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
