module Neuma
  # Client of the Neuma API
  # http://neuma.huma-num.fr/home/services
  class Client
    HOST = 'http://neuma.huma-num.fr'
    BASE_PATH = '/rest/collections'

    # there are multiple main corpora, but only the Sequentia one is relevant for our purposes
    DEFAULT_CORPUS = 'sequentia'

    def initialize
      @connection = Faraday.new(url: HOST) do |f|
        f.response :json
        f.response :raise_error
      end
    end

    def subcorpora(corpus_ref=DEFAULT_CORPUS)
      fetch_list "/#{corpus_ref}/_corpora/"
    end

    def opera(subcorpus_ref, corpus_ref=DEFAULT_CORPUS)
      fetch_list "/#{corpus_ref}/#{subcorpus_ref}/_opera/"
    end

    private

    def fetch_list(path)
      @connection
        .get(BASE_PATH + path)
        .body
        .collect(&OpenStruct.method(:new))
    end
  end
end
