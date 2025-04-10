module Gregobase
  class ChantsController < ApplicationController
    def index
      @source = Source.find request[:source_id]
      @chants = @source.chants.page(request[:page] || 1)
      @imported_ids = Set.new(
        ::Chant
          .select(:gregobase_chant_id)
          .where(gregobase_chant_id: @chants.collect(&:id))
          .pluck(:gregobase_chant_id)
      )
      @relevant_genres = Set.new(GregobaseImporter::GENRES.keys)
    end

    def show
      # TODO
    end
  end
end