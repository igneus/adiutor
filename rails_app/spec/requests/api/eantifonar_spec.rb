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

    it 'returns chant details if found' do
      lyrics = 'lyrics'
      chant = create(
        :chant,
        modus: 'I',
        differentia: 'D',
        lyrics_normalized: LyricsNormalizer.new.normalize_latin(lyrics),
        genre: create(:genre, system_name: 'antiphon'),
        source_language: create(:source_language, system_name: 'lilypond')
      )
      post path, params: {my_id: {lyrics: lyrics, lang: 'la'}}

      expect(response).to have_http_status :ok
      expect(response.body).to start_with '{"my_id":[{"id":'
      expect(response.body).to include '"modus":"I","differentia":"D","genre":"antiphon"'
    end

    describe 'non-standard input handling' do
      {
        'unsupported lang' => {my_id: {lyrics: 'Die Worte, die ich zu euch sprach', lang: 'de'}},
        'missing lyrics key' => {my_id: {lang: 'cs'}},
        'missing lang key' => {my_id: {lyrics: 'amen'}},
        'non-string values' => {my_id: {lyrics: [1, 2, 3], lang: 4}},
        'input right in the top-level mapping' => {lyrics: 'amen', lang: 'cs'},
        'top-level element a list' => [{lyrics: 'amen', lang: 'cs'}],
        'top-level element a scalar' => 'amen',
      }.each_pair do |label, payload|
        it label do
          post path, params: payload.to_json

          expect(response).to have_http_status :bad_request
          expect(response.body).to include '"error":'
          expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
        end
      end
    end
  end
end
