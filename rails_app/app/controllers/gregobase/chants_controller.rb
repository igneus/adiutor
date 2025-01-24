module Gregobase
  class ChantsController < ApplicationController
    def index
      @source = Source.find request[:source_id]
      @chants = @source.chants.page(request[:page] || 1)
    end

    def show
      # TODO
    end
  end
end