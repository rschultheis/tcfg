require_relative 'tcfg_helper'

module TCFG
  class Base
    include TCFG::Helper

    #the preferred way to acces... using []
    def [] key
      tcfg_get key
    end
  end
end
