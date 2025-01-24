require 'rails_helper'

RSpec.describe "Gregobase::Chants", type: :request do
  describe "GET /index" do
    it "returns http success" do
      source = create :gregobase_source
      get "/gregobase/sources/#{source.id}/chants"
      expect(response).to have_http_status(:success)
    end
  end

  # describe "GET /show" do
  #   it "returns http success" do
  #     get "/gregobase/chants/show"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
