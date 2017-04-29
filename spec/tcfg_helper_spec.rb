SAMPLE_CONFIG_FILE = File.expand_path('../sample_configs/sample1.yml', __FILE__)
SAMPLE_SECRET_CONFIG_FILE = File.expand_path('../sample_configs/sample1x.secret.yml', __FILE__)

describe TCFG::Helper do
  subject { Class.new { include TCFG::Helper }.new }

  describe 'each config tier independently' do
    it 'should support configuration from code using set method' do
      subject.instance_eval do
        tcfg_set :browser, 'firefox'
        tcfg_get(:browser).should == 'firefox'

        tcfg['browser'].should == 'firefox'
      end
    end

    it 'support picking up configuration from a config file' do
      subject.instance_eval do
        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg.keys.include?('sample_string').should == true
        tcfg['sample_string'].should == 'sample_string_value'

        tcfg_get('sample_integer').should == 123
      end
    end

    it 'support picking up configuration from a secret config file' do
      subject.instance_eval do
        tcfg_secret_config_file SAMPLE_SECRET_CONFIG_FILE
        tcfg.keys.include?('sample_secret_username').should == true
        tcfg['sample_secret_username'].should == 'this_is_a_username'
      end
    end

    it 'should support overriding based on T_ENVIRONMENT by default' do
      ENV['T_ENVIRONMENT'] = 'QA'
      subject.instance_eval do
        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg['sample_string'].should == 'this_is_QA_environment'
        tcfg['sample_string_two'].should == 'a value only in QA environment'

        tcfg_reset
        ENV['T_ENVIRONMENT'] = 'DEV'
        tcfg['sample_string'].should == 'this_is_DEV_environment'
      end
    end

    it 'should take environment from secret file if defined' do
      ENV['T_ENVIRONMENT'] = 'QA'
      subject.instance_eval do
        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg_secret_config_file SAMPLE_SECRET_CONFIG_FILE

        tcfg['sample_string'].should == 'secret_QA_setting'

        # this is defined in the normal/non-secret file only.  It is still available
        tcfg['sample_string_two'].should == 'a value only in QA environment'

        # the resolved config should include the environmet...its useful
        tcfg['T_ENVIRONMENT'].should == 'QA'
      end
    end

    it 'should support overriding based on environment variables prefixed with T_ by default' do
      ENV['T_sample_string'] = 'overridden'
      subject.instance_eval do
        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg['sample_string'].should == 'overridden'
      end
    end
  end

  describe '#tcfg_fetch' do
    before(:each) do
      subject.tcfg_set :a_config_key, 'a_config_value'
    end

    it 'should return the same value as tcfg_get for defined config' do
      subject.tcfg_get(:a_config_key).should eql('a_config_value')
      subject.tcfg_fetch(:a_config_key).should eql('a_config_value')
    end

    it 'should return nil if key and second argument is not defined' do
      subject.tcfg_fetch(:non_existent_config).should be_nil
      # contrast with behavior of tcfg_get
      expect { subject.tcfg_get(:non_existent_config) }.to raise_error(TCFG::NoSuchConfigurationKeyError)
    end

    it 'should return default value(second argument) if key is not defined' do
      subject.tcfg_fetch(:non_existent_config, 'my_default_value').should eql('my_default_value')
    end

  end


  describe 'configuring a custom environment variable prefix' do
    it 'should allow changing environment variable prefix to a custom value' do
      subject.tcfg_set_env_var_prefix('CUST_')
      ENV['CUST_ENVIRONMENT'] = 'QA'
      ENV['CUST_sample_string'] = 'environmental override'
      subject.tcfg_config_file SAMPLE_CONFIG_FILE
      subject.tcfg_secret_config_file SAMPLE_SECRET_CONFIG_FILE
      subject.tcfg['sample_negative_integer'].should == -12
      subject.tcfg['sample_secret_username'].should == 'this_is_a_username'
      subject.tcfg['sample_string_two'].should == 'using CUST_ for the environment prefix'
      subject.tcfg['sample_string'].should eql 'environmental override'
    end
  end

  describe 'preventing invalid usage' do
    it 'should give a clear exception if a non-existent environment is specified' do
      ENV['T_ENVIRONMENT'] = 'NOTREAL'
      expect { subject.tcfg }.to raise_error(TCFG::NoSuchEnvironmentError)
    end

    it 'should give a clear exception if a non-existent config file is specified' do
      expect { subject.tcfg_config_file 'fake.yml' }.to raise_error(TCFG::NoSuchConfigFileError)
      expect { subject.tcfg_secret_config_file 'fake.yml' }.to raise_error(TCFG::NoSuchConfigFileError)
    end

    it 'should give a clear exception is non-existent key is requested' do
      expect { subject.tcfg_get 'fake_key' }.to raise_error(TCFG::NoSuchConfigurationKeyError)
    end
  end

  # retrieved config should always be immutable.  Changing it should not affect what comes out of further retrievals
  describe 'tcfg immutablability' do
    before(:each) do
      subject.tcfg_config_file SAMPLE_CONFIG_FILE
    end

    it 'the top level hash should be frozen to discourage mutating it' do
      retrieved_cfg = subject.tcfg
      retrieved_cfg.should be_frozen
      expect { retrieved_cfg['sample_string'] = 'new_value' }.to raise_error(RuntimeError)
    end

    it 'should not persist changes to an array value in retrieved config' do
      retrieved_cfg = subject.tcfg
      retrieved_cfg['sample_array'] << 'added_element'
      subject.tcfg['sample_array'].last.should_not eql 'added_element'
      subject.tcfg['sample_array'].last.should eql 123
    end

    it 'should not change array value' do
      retrieved_cfg = subject.tcfg
      retrieved_cfg['sample_array'][0] = 'myedit'
      subject.tcfg['sample_array'][0].should_not eql 'myedit'
    end

    it 'should not change an array value in a hash' do
      retrieved_cfg = subject.tcfg
      retrieved_cfg['sample_hash']['h_a'][0] = 'myedit'
      subject.tcfg['sample_hash']['h_a'][0].should_not eql 'myedit'
    end
  end

  describe 'deep overriding based on environment variable' do
    before(:each) do
      h = {
        'aa' => 'AAAA',
        'bb' => %w[B BB],
        'cc' => {
          'dd' => 'DDD',
          'ee' => {
            'ff' => 'F'
          }
        }
      }
      subject.tcfg_set 'some_deep_config', h
      subject.tcfg['some_deep_config']['cc']['dd'].should eql 'DDD'
      subject.tcfg['some_deep_config']['cc']['ee']['ff'].should eql 'F'
    end

    it 'should allow for deep overriding deep config entirely' do
      ENV['T_some_deep_config'] = 'xxxx'
      subject.tcfg_reset
      subject.tcfg['some_deep_config'].should eql 'xxxx'
    end

    it 'should allow for deep overriding by seperating keys with a - character' do
      ENV['T_some_deep_config-aa'] = 'xxxx'
      ENV['T_some_deep_config-cc-dd'] = 'yyyy'
      ENV['T_some_deep_config-cc-ee-ff'] = 'zzzz'
      ENV['T_some_deep_config-cc-ee-ff'] = 'zzzz'
      subject.tcfg_reset

      subject.tcfg['some_deep_config']['aa'].should eql 'xxxx'
      subject.tcfg['some_deep_config']['cc']['dd'].should eql 'yyyy'
      subject.tcfg['some_deep_config']['cc']['ee']['ff'].should eql 'zzzz'
    end

    it 'should raise an exception if a bad parent is specified in a deep override' do
      ENV['T_some_deep_config-cc-xx-ff'] = 'xxxx'
      subject.tcfg_reset
      expect { subject.tcfg }.to raise_error(TCFG::BadParentInDeepOverrideError)
    end

    it 'should raise an exception is non existent config is overridden' do
      ENV['T_fake_config'] = 'xxxx'
      subject.tcfg_reset
      expect { subject.tcfg }.to raise_error(TCFG::NoSuchConfigurationKeyError)
    end

    it 'should raise an exception is non existent deep config is overridden' do
      ENV['T_some_deep_config-abc'] = 'xxxx'
      subject.tcfg_reset
      expect { subject.tcfg }.to raise_error(TCFG::NoSuchConfigurationKeyError)
    end
  end
end
