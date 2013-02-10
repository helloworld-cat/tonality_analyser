require 'spec_helper'

describe TonalityAnalyser::Engine do
  
  # Woouuu Wouuuu les test de la mort :)
  it 'propose tonality' do
    e = TonalityAnalyser::Engine.new
    e.flush
    e.load_traning_corpus!('training')
    e.compute_probabilities!
    e.tonality('This').should == :neg
    e.tonality('Unacceptable') == :neg
    e.tonality('want') == :pos
    e.tonality('Thanks') == :pos
  end
end
