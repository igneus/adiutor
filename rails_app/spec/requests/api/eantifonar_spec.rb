require 'rails_helper'

RSpec.describe "Api::Eantifonar", type: :request do
  describe "POST /api/eantifonar/search" do
    let(:path) { '/api/eantifonar/search' }

    it 'works with empty input' do
      post path, params: {}

      expect(response).to have_http_status :ok
      expect(response.body).to eq '{}'
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
    end

    it 'returns null if not found' do
      post path, params: {my_id: {lyrics: 'unknown lyrics', lang: 'cs'}}

      expect(response).to have_http_status :ok
      expect(response.body).to eq '{"my_id":null}'
    end

    # NOTE: since the code under test invokes image_url, it's quite possible
    # that these tests only pass if there are images with matching names
    # in the development asset pipeline, which is really unfortunate
    it 'returns chant details if found' do
      chant = create(
        :chant,
        modus: 'I',
        differentia: 'D',
        lyrics_normalized: 'lyrics',
        genre: create(:genre, system_name: 'antiphon'),
        source_language: create(:source_language, system_name: 'lilypond')
      )
      post path, params: {my_id: {lyrics: chant.lyrics_normalized, lang: 'la'}}

      expect(response).to have_http_status :ok
      expect(response.body).to start_with '{"my_id":[{"id":'
      expect(response.body).to include '"modus":"I","differentia":"D","genre":"antiphon"'
      expect(response.body).to include '"image":"http://www.example.com/assets/chants/lilypond/'
    end
  end
end
