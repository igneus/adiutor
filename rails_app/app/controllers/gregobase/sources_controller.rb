module Gregobase
  class SourcesController < ApplicationController
    def index
      @sources = Source.order(year: :desc, title: :asc)
    end

    def show
      redirect_to gregobase_source_chants_path(request[:id])
    end
  end
end
