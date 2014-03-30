require_relative 'tcfg_helper'


module TCFG
  # The TCFG::Base object can used an instance of configuration
  #
  # All of the methods from TCFG::Helper are available as instance methods
  #
  #     cfg = TCFG::Base.new
  #     cfg.tcfg_set 'my_key', 'my_value'
  #
  #     cfg['my_key']
  #     => 'my_value'
  #
  #     cfg.tcfg
  #     => { 'my_key' => 'my_value', ... }
  #
  class Base
    include TCFG::Helper

    #the simplest way to acces configuration
    #
    #    cfg['my_key']
    #    => 'some_value'
    #
    # @see TCFG::Helper#tcfg_get
    def [] key
      tcfg_get key
    end
  end
end
