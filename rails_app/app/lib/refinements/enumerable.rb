module Refinements
  module Enumerable
    refine ::Enumerable do
      # Runs the block for each element in the Enumerable,
      # returns the first non-nil result encountered.
      def first_nonempty_result(&blk)
        lazy
          .collect(&blk)
          .find {|x| !x.nil? }
      end
    end
  end
end
