require_relative 'tcfg_helper'

# The TCFG module can be used as singleton for accessing and specifying configuration
#
# All of the public methods from TCFG::Helper are available as class methods
# right off the TCFG module
#
#     TCFG.tcfg_set 'some_key', 'some_value'
#
#     TCFG['some_key']
#     => 'some_value'
#
#     TCFG.tcfg
#     => { 'some_key' => 'some_value', ... }
#
#
module TCFG
  class << self
    include TCFG::Helper

    #the simplest way to acces configuration
    #
    #    TCFG['my_key']
    #    => 'some_value'
    #
    # @see TCFG::Helper#tcfg_get
    def [] key
      tcfg_get key
    end
  end
end
