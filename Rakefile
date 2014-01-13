require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--fail-fast --color --order random'
end

task :test => :spec
task :default => :test
