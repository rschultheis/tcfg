require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'

require_relative 'tcfg_base'

module TCFG
  module Helper
    DEFAULT_CONFIG_FILE = 'tcfg.yml'

    def tcfg
      resolved_config = ActiveSupport::HashWithIndifferentAccess.new

      #tier 1 code defaults
      resolved_config.merge! tier_code_defaults

      #tier 2, the main config file
      resolved_config.merge! tier_config_file

      #tier 3, the main config file
      resolved_config.merge! tier_secret_config_file

      #tier 4, environment overrides
      resolved_config.merge! tier_environment_overrides

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
      if @tcfg_secret_config_filename
        tcfg_load_optional_config_file @tcfg_secret_config_filename
      elsif @tcfg_config_filename
        ext = File.extname @tcfg_config_filename
        base = File.basename @tcfg_config_filename, ext
        dir = File.dirname @tcfg_config_filename
        possible_secret_filename = dir + '/' + base + '.secret' + ext
        tcfg_load_optional_config_file possible_secret_filename
      else
        {}
      end
    end

    def tier_environment_overrides
      return {} unless @tcfg_environments_config and ENV['TCFG_ENVIRONMENT']
      @tcfg_environments_config[ENV['TCFG_ENVIRONMENT']]
    end

    def tcfg_load_optional_config_file filename
      @tcfg_environments_config ||= ActiveSupport::HashWithIndifferentAccess.new
      if File.exist? filename
        file_contents = YAML.load_file filename
        hashed = ActiveSupport::HashWithIndifferentAccess.new file_contents
        environments = hashed.delete :tcfg_environments
        @tcfg_environments_config.deep_merge!(environments) if environments
        hashed
      else
        {}
      end
    end

  end
end
