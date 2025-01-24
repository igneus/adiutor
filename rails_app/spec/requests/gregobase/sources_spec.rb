require 'rails_helper'

RSpec.describe "Gregobase::Sources", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/gregobase/sources"
      expect(response).to have_http_status(:success)
    end
  end

  # describe "GET /show" do
  #   it "returns http success" do
  #     get "/gregobase/sources/show"
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
