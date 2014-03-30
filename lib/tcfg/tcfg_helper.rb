require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'

module TCFG

  # TCFG::Helper does all the "heavy lifting".  Essentially all the logic within TCFG is defined by this module.
  # The intended ways to use this module are:
  #
  # - use the TCFG module methods whenever a single instance of configuration will do
  #
  #     TCFG['some_key']
  #     => 'some_value'
  #
  #     TCFG.tcfg
  #     => { 'some_key' => 'some_value', ... }
  #
  # - mix it into any class that needs configuration
  #
  #     Class MyClass
  #       include TCFG::Helper
  #     end
  #
  #     Myclass.new.tcfg
  #     => { 'some_key' => 'some_value', ... }
  #
  # - create a configuration instance object with this module pre-mixed in
  #
  #     cfg = TCFG::Base.new
  #     cfg['some_key']
  #     => 'some_value'
  #
  #     cfg.tcfg
  #     => { 'some_key' => 'some_value', ... }
  #
  #
  module Helper

    # the public config file that is looked for unless tcfg_config_file is called
    DEFAULT_CONFIG_FILE = 'tcfg.yml'

    # return a copy of the resolved configuration
    #
    # This is the preferred way to access a complete copy of the fully resolved configuration.
    #
    # @return [ActiveSupport::HashWithIndifferentAccess] a copy of the resolved configuration
    def tcfg
      @tcfg_resolved_config ||= resolve_config
      #return a copy of the configuration object to prevent mutations
      Marshal.load(Marshal.dump(@tcfg_resolved_config))
    end

    # change the name of the public configuration file
    #
    # Changing the name of the public configuration file also
    # changes the default secret configuration file.
    # For example calling #tcfg_config_file('my_cfg.ym') will
    # cause TCFG to look for 'my_cfg.secret.yml' for the secret
    # file unless #tcfg_secret_config_file is also called.
    #
    # @see #tcfg_secret_config_file
    #
    # @param filename [String] the path to a yaml file
    # @return [nil]
    #
    def tcfg_config_file filename
      confirm_config_file_existence  filename
      tcfg_reset
      @tcfg_config_filename = filename
      nil
    end

    # change the name of the secret configuration file
    #
    # Calling this method if neccesary only if:
    # - you dont have a public configuration file, or
    # - your secret file is not named like <public name>.secret.yml
    #
    # @param filename [String] the path to a yaml file
    # @return [nil]
    #
    def tcfg_secret_config_file filename
      confirm_config_file_existence  filename
      tcfg_reset
      @tcfg_secret_config_filename = filename
      nil
    end

    # to correct way to default configuration is to use tcfg_set
    #
    # @param key [String] the configuration key name
    # @param value [String, Integer, FixNum, Array, Hash] the value of the configuration
    # @return value The same value that was passed in
    #
    def tcfg_set key, value
      tier_code_defaults[key] = value
      tcfg_reset
      return value
    end

    # return a single piece of configuration by key
    #
    # @param key [String] the configuration to return
    # @return [String, Integer, FixNum, Array, Hash] the value of the configuration from the resolved configuration
    #
    def tcfg_get key
      t_tcfg = tcfg
      unless t_tcfg.has_key? key
        raise NoSuchConfigurationKeyError.new "No configuration defined for '#{key}'"
      end
      t_tcfg[key]
    end

    # force tcfg to re-resolve the configuration
    #
    # This method can be called to force tcfg to re-resolve the configuration.
    # This generally should not be needed directly, but situations where it 
    # could be used include:
    # - The underlying config file(s) have changed and you want to re-read them
    # - The underlying ENV environment variables have changed and you want to re-read them
    #
    # @return [nil]
    #
    def tcfg_reset
      @tcfg_resolved_config = nil
    end

    # change the prefix used for configuration finding
    #
    # By default TCFG looks for 
    # - environment variables prefixed with T_
    # - sections in config files called t_environments
    #
    # This method lets you change that to any prefic you want.
    # For example calling it like this:
    #
    #     TCFG.tcfg_set_env_var_prefix 'MY_'
    #
    # Will cause tcfg to look for:
    # - environment variables prefixed with MY_
    # - sections in config files called my_environments
    #
    # @param prefix [String] the new prefix. It can be an empty string to specify no prefix should be used.
    # @return [nil]
    #
    def tcfg_set_env_var_prefix prefix
      @tcfg_env_var_prefix = prefix
      tcfg_reset
    end

    private

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
      tenv = tcfg_fetch_env_var 'ENVIRONMENT', nil
      return {} unless @tcfg_environments_config and tenv
      unless @tcfg_environments_config.has_key? tenv
        raise TCFG::NoSuchEnvironmentError.new "No such environment in configuration '#{tenv}'"
      end
      @tcfg_environments_config[tenv].merge({tcfg_env_var_name('ENVIRONMENT') => tenv})
    end

    def tcfg_load_optional_config_file filename
      @tcfg_environments_config ||= ActiveSupport::HashWithIndifferentAccess.new
      if File.exist? filename
        file_contents = YAML.load_file filename
        hashed = ActiveSupport::HashWithIndifferentAccess.new file_contents
        environments = hashed.delete tcfg_env_var_name('environments').downcase
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

    def tcfg_env_var_name key
      @tcfg_env_var_prefix ||= 'T_'
      @tcfg_env_var_prefix + key
    end

    def tcfg_fetch_env_var key, not_defined_value
      ENV.fetch tcfg_env_var_name(key), not_defined_value
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
        resolved_config[k] = tcfg_fetch_env_var(k, v)
      end
      resolved_config
    end

  end

  #Raised when the requested environment is not available
  class NoSuchEnvironmentError < StandardError; end

  #raised when a non-existent config file is specified
  class NoSuchConfigFileError < StandardError; end

  #raise when a non-existent piece of configuration is requested
  class NoSuchConfigurationKeyError < StandardError; end
end
