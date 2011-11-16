begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue LoadError => e
  warn "[WARNING]: It is recommended that you use bundler during development: gem install bundler"
end

require "rspec/core/rake_task"

desc "Test typography plugin."
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec
