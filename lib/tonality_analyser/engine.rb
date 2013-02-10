module TonalityAnalyser

  # Refactor: work to Redis !
  #   Redis ! Redis ! Redis ! Redis ! Redis ! :)
  class Engine
    TONALITIES = [:pos, :neg]
    attr_reader :counted_words, :probabilites
    def initialize
      @total_words = {}
      @total_words[:pos] = 0
      @total_words[:neg] = 0
      @counted_words = {}
      @counted_words[:pos] = {}
      @counted_words[:neg] = {}
      @probabilites = {}
      @probabilites[:pos] = {}
      @probabilites[:neg] = {}
    end
    def train(words, tonality)
      raise "Invalid tonality '#{tonality}'" unless TONALITIES.include?(tonality)
      words.split.each do |w|
        word = Helpers::Text.normalize(w)
        @counted_words[tonality][word] = @counted_words[tonality].include?(word) ? @counted_words[tonality][word]+1 : 1
      end
    end
    def compute_probabilities!
      # TODO: Refactor this :)
      @counted_words[:pos].each do |word, count|
        @probabilites[:pos][word] = @counted_words[:pos][word].to_f / (@counted_words[:pos][word].to_f + @counted_words[:neg][word].to_f)
      end
      @counted_words[:neg].each do |word, count|
        @probabilites[:neg][word] = @counted_words[:neg][word].to_f / (@counted_words[:pos][word].to_f + @counted_words[:neg][word].to_f)
      end
    end
    def analysis(text, tonality)
      num, den1, den2 = 1.0, 1.0, 1.0

      words = Helpers::Text.clean_words_from(text)
      words.each do |word|
        p = @probabilites[tonality][word] || 0.01
        num *= p
      end
      num *= 0.5
      words.each do |word|
        p = @probabilites[tonality][word] || 0.01
        den1 *= p
      end
      words.each do |word|
        p = @probabilites[tonality][word] || 0.01
        den2 *= (1 - p)
      end
      proba_pol = num / (den1 + den2)
      proba_pol = 0.0 if proba_pol.nan?
      proba_pol
    end
    def tonality(text)
      pos_proba = analysis(text, :pos)
      neg_proba = analysis(text, :neg)
      pos_proba >= neg_proba ? :pos : :neg
    end
    def load_traning_corpus!(dir)
      TONALITIES.each { |tonality| load_traning_corpus_for(dir, tonality) }
    end
    def load_traning_corpus_for(dir, tonality)
      File.open("#{dir}/#{tonality}.txt", 'r') do |f|
        f.each_line { |line| train(line, tonality) }
        f.close
      end
    end
  end
end
