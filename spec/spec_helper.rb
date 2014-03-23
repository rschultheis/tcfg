require 'bundler/setup'
Bundler.setup

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
