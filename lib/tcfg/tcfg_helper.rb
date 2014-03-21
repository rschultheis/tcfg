require 'yaml'

require_relative 'tcfg_base'

module TCFG
  module Helper
    DEFAULT_CONFIG_FILE = 'tcfg.yml'
    DEFAULT_SECRET_CONFIG_FILE = 'tcfg.secret.yml'

    def tcfg
      resolved_config = {}

      #tier 1 code defaults
      resolved_config.merge! tier_code_defaults

      #tier 2, the main config file
      resolved_config.merge! tier_config_file

      #tier 3, the main config file
      resolved_config.merge! tier_secret_config_file


      #tier 5, environment variable overrides
      resolved_config.each_pair do |k, v|
        env_var_name = "TCFG_#{k}"
        resolved_config[k] = ENV.fetch(env_var_name, v)
      end
      return resolved_config
    end

    def tcfg_config_file filename
      @tcfg_config_filename = filename
    end

    def tcfg_secret_config_file filename
      @tcfg_secret_config_filename = filename
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
    def tier_code_defaults
      @tcfg_code_defaults ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def tier_config_file
      @tcfg_config_filename ||= DEFAULT_CONFIG_FILE
      tcfg_load_optional_config_file @tcfg_config_filename
    end

    def tier_secret_config_file
      @tcfg_secret_config_filename ||= DEFAULT_CONFIG_FILE
      tcfg_load_optional_config_file @tcfg_secret_config_filename
    end

    def tcfg_load_optional_config_file filename
      if File.exist? filename
        file_contents = YAML.load_file filename
        ActiveSupport::HashWithIndifferentAccess.new file_contents
      else
        {}
      end
    end

  end
end
