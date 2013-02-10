module TonalityAnalyser
  module Helpers

    class Text
      def self.normalize(word)
        word.downcase.gsub(/[^0-9a-z]/i, '')
      end
      def self.clean_words_from(text)
        text.downcase.gsub(/[^0-9a-z]/i, ' ').split.inject([]) do |words, w|
          words << w if w.length > 2
          words
        end
      end
    end

  end
end
