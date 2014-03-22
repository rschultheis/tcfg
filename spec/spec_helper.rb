require 'bundler/setup'
Bundler.setup

require 'simplecov'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_profile 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'tcfg'

RSpec.configure do |config|

  #remove environment variables laying around from last test
  config.before(:each) do
    ENV.delete_if {|k| k =~ /^TCFG_/ }
  end

end
