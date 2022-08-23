require 'rails_helper'

# Smoke tests
RSpec.describe "Routes served by HomeController", type: :request do
  describe "GET /" do
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
    end

    it 'succeeds' do
      get '/psalm_tunes'
      expect(response).to have_http_status :ok
    end
  end
end
