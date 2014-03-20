require 'yaml'

require_relative 'tcfg_base'

module TCFG
  module Helper
    TCFG_TIERS = [:tier_code_defaults, :tier_config_file]

    DEFAULT_CONFIG_FILE = 'tcfg.yml'

    def tcfg
      resolved_config = {}
      TCFG_TIERS.each do |tier|
        resolved_config = resolved_config.merge(self.send(tier))
      end

      resolved_config.each_pair do |k, v|
        resolved_config[k] = ENV.fetch(k, v)
      end
      return resolved_config
    end

    def tcfg_config_file filename=DEFAULT_CONFIG_FILE
      @tcfg_config_filename = filename
      file_contents = YAML.load_file filename
      tier_config_file.clear
      tier_config_file.merge! file_contents
    end

    def tcfg_set key, value
      tier_code_defaults[key] = value
      return value
    end

    def tcfg_get key
      tier_code_defaults[key]
    end

    private

    #define how we handle state for each of the tiers
    TCFG_TIERS.each do |config_tier|
      define_method config_tier do
        inst_var_name = "@#{config_tier.to_s}"
        unless instance_variable_defined? inst_var_name 
          instance_variable_set(inst_var_name, ActiveSupport::HashWithIndifferentAccess.new)
        end
        instance_variable_get(inst_var_name)
      end
    end

  end
end
