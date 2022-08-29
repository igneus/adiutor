require 'rails_helper'

RSpec.describe 'Corpora', type: :request do
  describe 'GET /corpora/:id/differentiae' do
    it 'works' do
      corpus = create :corpus
      chant = create :chant, corpus: corpus, volpiano: '1---h--h--', genre: create(:genre, system_name: 'antiphon')

      get "/corpora/#{corpus.id}/differentiae"
      expect(response).to have_http_status :ok
      expect(response.body).to include chant.volpiano
    end
  end
end
