require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'

require_relative 'tcfg_base'

module TCFG
  module Helper
    DEFAULT_CONFIG_FILE = 'tcfg.yml'

    def tcfg
      @tcfg_resolved_config ||= resolve_config
      #return a copy of the configuration object to prevent mutations
      Marshal.load(Marshal.dump(@tcfg_resolved_config))
    end

    def tcfg_config_file filename
      confirm_config_file_existence  filename
      tcfg_reset
      @tcfg_config_filename = filename
    end

    def tcfg_secret_config_file filename
      confirm_config_file_existence  filename
      tcfg_reset
      @tcfg_secret_config_filename = filename
    end

    def tcfg_set key, value
      tier_code_defaults[key] = value
      tcfg_reset
      return value
    end

    def tcfg_get key
      t_tcfg = tcfg
      unless t_tcfg.has_key? key
        raise NoSuchConfigurationKeyError.new "No configuration defined for '#{key}'"
      end
      t_tcfg[key]
    end

    def tcfg_reset
      @tcfg_resolved_config = nil
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
      tenv = ENV['TCFG_ENVIRONMENT']
      return {} unless @tcfg_environments_config and tenv
      unless @tcfg_environments_config.has_key? tenv
        raise TCFG::NoSuchEnvironmentError.new "No such environment in configuration '#{tenv}'"
      end
      @tcfg_environments_config[tenv].merge({'TCFG_ENVIRONMENT' => tenv})
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

    def confirm_config_file_existence filename
      unless File.exist? filename
        raise TCFG::NoSuchConfigFileError.new "No such config file '#{filename}'"
      end
    end

    def resolve_config
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
      resolved_config
    end

  end

  #custom exceptions
  class NoSuchEnvironmentError < StandardError; end
  class NoSuchConfigFileError < StandardError; end
  class NoSuchConfigurationKeyError < StandardError; end
end
