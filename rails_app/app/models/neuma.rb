# Client of the Neuma API
# http://neuma.huma-num.fr/home/services
module Neuma
  BASE_URL = 'http://neuma.huma-num.fr/rest/collections'

  # there are multiple main corpora, but only the Sequentia one is relevant for our purposes
  DEFAULT_CORPUS = 'sequentia'

  class Corpus
    class << self
      def all(corpus_ref=DEFAULT_CORPUS)
        fetch_list BASE_URL + "/#{corpus_ref}/_corpora/"
      end

      def opera(subcorpus_ref, corpus_ref=DEFAULT_CORPUS)
        fetch_list BASE_URL + "/#{corpus_ref}/#{subcorpus_ref}/_opera/"
      end

      private

      def fetch_list(uri)
        JSON.load(Faraday.get(uri).body)
          .collect(&OpenStruct.method(:new))
      end
    end
  end
end
