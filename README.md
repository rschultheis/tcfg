TCFG
====
Test suite configuration for the real world of software development


Test suite configuration manifesto
----------------------------------

We hereby declare that executors of test suites have the following rights:

* You shall be able to control your test suite using environment variables.
  _You shall not be required to edit config files in order to run your test suite in the desired way.
  This decree will ensure your test suite integrates easily into any continous integration system._

* Your test configuration shall make it easy to support test execution against your various environments
  (QA, Staging, Production, local development, etc).  _You shall be able to control the environment using
  a single environment variable._

Accordingly, we enact the following principles that shall govern the land of test configuration:

* Configuration should be used only when needed.  The convention-over-configuration paradigm should be used wherever 
  possible to avoid excessive coniguration.

* Test suite configuration should generally not be conflated with test data or reference data.  Separate management
  of test data is encouraged except for cases where only a very small amount of test data is needed.


The tiers of configuration
--------------------------

TCFG implements a tiered approach to configuration which is designed to maximize flexibility and ensure a test suite is easy to control.

#### Properties of configuration tiers

* Each configuration tier is optional.
* A config variable in any tier overrides settings in lower tiers.

#### The tiers:

* **Defaults** defined in code

* **Public Defaults** defined in tcfg.yml config file

* **Private configuration** defined in tcfg.secret.yml file.  This file should generally not be checked into source control as it is 
  intended to contain things like passwords and/or API keys or any sensistive data.

* **Environment overrides** which can be defined in special 'environments' sections of either tcfg.yml or tcfg.secret.yml

* **Environment variables** can override any peice of configuration.  A Special TCFG_ENVIRONMENT environment variable can be used for macro level control
  of all environment based overrides.



Example
-------

An example is a big TODO here.  Will prefer to link to the example rspec capybara test suite once it oncorporates this gem.


