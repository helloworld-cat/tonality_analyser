require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default => :spec
desc 'Run tests with RSpec'
RSpec::Core::RakeTask.new(:spec) do |s|
  s.rspec_opts = '--color'
end
