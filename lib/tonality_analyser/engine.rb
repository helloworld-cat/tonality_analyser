require 'redis'

module TonalityAnalyser

  class Engine
    TONALITIES = [:pos, :neg]
    attr_reader :counted_words, :probabilites
    REDIS_PREFIX = 'tonality_analyser'
    def initialize
      @redis = Redis.new
      @redis.keys(redis_key('*')).each { |key| @redis.del(key) }
    end
    def redis_key(name)
      "#{REDIS_PREFIX}:#{name}"
    end
    def train(words, tonality)
      raise "Invalid tonality '#{tonality}'" unless TONALITIES.include?(tonality)
      words.split.each do |w|
        word = Helpers::Text.normalize(w)
        # @counted_words[tonality][word] = @counted_words[tonality].include?(word) ? @counted_words[tonality][word]+1 : 1
        @redis.incr redis_key("words:#{tonality}:#{word}")
      end
    end
    def compute_probabilities!
      # @counted_words[:pos].each do |word, count|
      #   @probabilites[:pos][word] = @counted_words[:pos][word].to_f / (@counted_words[:pos][word].to_f + @counted_words[:neg][word].to_f)
      # end

      # TODO: use "multi redis"
      @redis.keys(redis_key("words:pos:*")).each do |key|
        count = @redis.get(key)
        word = key[redis_key('words:pos:').length..key.length]
        a = @redis.get(redis_key("words:pos:#{word}")).to_f
        b = @redis.get(redis_key("words:neg:#{word}")).to_f
        p = a / (a + b)
        @redis.set redis_key("probabilites:pos:#{word}"), p
      end

      # @counted_words[:neg].each do |word, count|
      #   @probabilites[:neg][word] = @counted_words[:neg][word].to_f / (@counted_words[:pos][word].to_f + @counted_words[:neg][word].to_f)
      # end
      @redis.keys(redis_key("words:neg:*")).each do |key|
        count = @redis.get(key)
        word = key[redis_key('words:neg:').length..key.length]
        a = @redis.get(redis_key("words:neg:#{word}")).to_f
        b = @redis.get(redis_key("words:pos:#{word}")).to_f
        p = a / (a + b)
        @redis.set redis_key("probabilites:neg:#{word}"), p
      end
    end
    def analysis(text, tonality)
      num, den1, den2 = 1.0, 1.0, 1.0

      words = Helpers::Text.clean_words_from(text)
      words.each do |word|
        # p = @probabilites[tonality][word] || 0.01
        p = @redis.get(redis_key("probabilites:#{tonality}:#{word}")) || 0.01
        num *= p.to_f
      end
      num *= 0.5
      words.each do |word|
        # p = @probabilites[tonality][word] || 0.01
        p = @redis.get(redis_key("probabilites:#{tonality}:#{word}")) || 0.01
        den1 *= p.to_f
      end
      words.each do |word|
        # p = @probabilites[tonality][word] || 0.01
        p = @redis.get(redis_key("probabilites:#{tonality}:#{word}")) || 0.01
        den2 *= (1 - p.to_f)
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
