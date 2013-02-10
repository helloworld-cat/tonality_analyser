# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tonality_analyser/version'

Gem::Specification.new do |gem|
  gem.name          = "tonality_analyser"
  gem.version       = TonalityAnalyser::VERSION
  gem.authors       = ["Samuel Sanchez"]
  gem.email         = ["samuel@pagedegeek.com"]
  gem.description   = %q{Process text and propose tonality.}
  gem.summary       = %q{Process text and propose tonality with bayes computation}
  gem.homepage      = "http://github.com/PagedeGeek/tonality_analyser"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
