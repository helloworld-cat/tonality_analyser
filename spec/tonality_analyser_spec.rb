require 'spec_helper'

describe TonalityAnalyser::Engine do
  
  # Woouuu Wouuuu les test de la mort :)
  it 'propose tonality' do
    e = TonalityAnalyser::Engine.new
    e.load_traning_corpus!('training')
    e.compute_probabilities!
    e.tonality('This').should == :neg
    e.tonality('Unacceptable') == :neg
    e.tonality('want') == :pos
    e.tonality('Thanks') == :pos
  end

  it 'propose tonality' do
    e = TonalityAnalyser::Engine.new
    e.train "c'est super !", :pos
    e.train "encore un beau ", :pos
    e.train "nul nul nul", :neg
    e.train "pas tres beau projet", :neg
    e.compute_probabilities!
    e.tonality('super beau projet').should == :pos
    e.tonality('c\'est nul').should == :neg
  end

end
