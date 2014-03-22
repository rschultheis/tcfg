TCFG
====

TCFG (pronounced "tee config") is test suite configuration for the real world.  TCFG offers:

* Support for easily controlling which environment your tests execute against

* A tiered structure to configuration which allows for every kind of configuration scenario to be supported.

Background
----------

The Wiki contains more in depth information.  Some good places to start:

* [Test suite configuration manifesto](https://github.com/rschultheis/tcfg/wiki/Test-Suite-Configuration-Manifesto)

* [The tiers of configuration in TCFG](https://github.com/rschultheis/tcfg/wiki/The-tiers-of-configuration-in-TCFG)


Getting started
---------------

### Using in RSpec

Start by installing the gem:

    $ gem install tcfg

In the project root, make a yaml file called tcfg.yml that contains all configuration you want to be able to control.  For a selenium suite, it might look something like this:

    ---
    #start with basic defaults
    BROWSER: firefox
    BASE_URL: http://localhost:8080
    LOG_LEVEL: INFO

    #This is a special section with overrides by 'environment'
    tcfg_environments:
      QA:
        BASE_URL: http://qa.mysite.com

      Production:
        BASE_URL: https://mysite.com

Then configure RSpec to use tcfg in your spec helper file (typically called spec/spec_helper.rb):

    require 'tcfg'

    RSpec.configure do |config|
      config.include TCFG::Helper
    end

Now you can access configuration in any before, after, or it block, like:

    require 'selenium-webdriver'
    RSpec.configure do |config|
      config.before(:all) do
        @browser = Selenium::WebDriver.for tcfg['BROWSER']
      end

      config.before(:each) do
        @browser.get tcfg['BASE_URL']
      end

      config.after(:all) do
        @browser.quit
      end
    end

If you need to access configuration outside of a before, after, or it block you can use the TCFG module directly:

    Log.level = TCFG.tcfg['LOG_LEVEL']

To control your test suite, you can use environment variables.  To change the browser used:

    #To execute with all default configuration
    $ rspec

    #To change the browser used
    $ TCFG_BROWSER=chrome rspec

    #To change which environment the tests execute against:
    $ TCFG_ENVIRONMENT=QA rspec


### Other uses

TCFG is a general purpose configuration framework.  It should be possible to use with most Ruby test frameworks or even for non testing uses.  If you have a use and aren't sure how to handle it with tcfg, file an issue we'll see if we can help you out.


