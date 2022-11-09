require 'rails_helper'

# Smoke tests
RSpec.describe 'Routes served by HomeController', type: :request do
  describe 'GET /' do
    before :each do
      create :in_adiutorium_corpus
    end

    it 'succeeds' do
      get '/'
      expect(response).to have_http_status :ok
      expect(response.body).to include 'Adiutor'
    end
  end

  describe 'GET /overview' do
    it 'succeeds' do
      get '/overview'
      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /psalm_tunes' do
    before :each do
      Genre.create!(system_name: 'invitatory')
      create :in_adiutorium_corpus
    end

    it 'succeeds' do
      get '/psalm_tunes'
      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /chant_of_the_day' do
    it 'succeeds' do
      get '/chant_of_the_day'
      expect(response).to have_http_status :ok
    end
  end

  describe 'editfial redirect back' do
    it 'displays error message from the query string as a flash message' do
      get '/overview?editfialError=My%20error%20message&otherParams=are&not=harmed'
      follow_redirect!
      expect(response.body).to include '<div class="flash flash-error">My error message'
      expect(request.url).to end_with '/overview?not=harmed&otherParams=are'
    end
  end
end
