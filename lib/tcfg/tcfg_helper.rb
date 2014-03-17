require_relative 'tcfg_base'

module TCFG
  module Helper

    def tcfg_set key, value
      tcfg_code_defaults[key] = value
      return value
    end

    def tcfg_get key
      tcfg_code_defaults[key]
    end

    private
    def tcfg_code_defaults
      @tcfg_code_defaults ||= ActiveSupport::HashWithIndifferentAccess.new
    end

  end
end
