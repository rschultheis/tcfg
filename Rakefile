# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_co
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = 'tcfg'
  gem.homepage = 'http://github.com/rschultheis/tcfg'
  gem.license = 'MIT'
  gem.summary = 'Test suite configuration for the real world'
  gem.description = 'A tiered approach to configuration which allows for full control of your test suite through environment variables'
  gem.email = 'robert.schultheis@gmail.com'
  gem.authors = ['robert schultheis']
  gem.files = [
    'Gemfile',
    'Gemfile.lock',
    'LICENSE.txt',
    'README.md',
    'Rakefile',
    'VERSION'
  ] + Dir.glob('lib/**/*.rb')

  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task default: :spec

# YARD for documentation
require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end
