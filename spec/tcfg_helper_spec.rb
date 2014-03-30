SAMPLE_CONFIG_FILE = File.expand_path('../sample_configs/sample1.yml', __FILE__)
SAMPLE_SECRET_CONFIG_FILE = File.expand_path('../sample_configs/sample1x.secret.yml', __FILE__)

describe TCFG::Helper do

  subject { Class.new { include TCFG::Helper }.new }

  describe "each config tier independently" do
    it "should support configuration from code using set method" do
      subject.instance_eval do
        tcfg_set :browser, 'firefox'
        tcfg_get(:browser).should == 'firefox'

        tcfg['browser'].should == 'firefox'
      end
    end

    it "support picking up configuration from a config file" do
      subject.instance_eval do

        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg.keys.include?('sample_string').should == true
        tcfg['sample_string'].should == 'sample_string_value'

        tcfg_get('sample_integer').should == 123

      end
    end

    it "support picking up configuration from a secret config file" do
      subject.instance_eval do

        tcfg_secret_config_file SAMPLE_SECRET_CONFIG_FILE
        tcfg.keys.include?('sample_secret_username').should == true
        tcfg['sample_secret_username'].should == 'this_is_a_username'

      end
    end

    it "should support overriding based on T_ENVIRONMENT" do
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

    it "should take environment from secret file if defined" do
      ENV['T_ENVIRONMENT'] = 'QA'

      subject.instance_eval do

        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg_secret_config_file SAMPLE_SECRET_CONFIG_FILE

        tcfg['sample_string'].should == 'secret_QA_setting'

        #this is defined in the normal/non-secret file only.  It is still available
        tcfg['sample_string_two'].should == 'a value only in QA environment'

        #the resolved config should include the environmet...its useful
        tcfg['T_ENVIRONMENT'].should == 'QA'
      end

    end

    it "should support overriding based on environment variables prefixed with T_" do
      ENV['T_sample_string'] = 'overridden'
      subject.instance_eval do
        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg['sample_string'].should == 'overridden'
      end
    end

    it "should support overriding based on environment variables prefixed with T_" do
      ENV['T_sample_string'] = 'overridden'
      subject.instance_eval do
        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg['sample_string'].should == 'overridden'
      end
    end

  end

  describe "preventing invalid usage" do
    it "should give a clear exception if a non-existent environment is specified" do
      ENV['T_ENVIRONMENT'] = 'NOTREAL'
      expect { subject.tcfg }.to raise_error(TCFG::NoSuchEnvironmentError)
    end

    it "should give a clear exception if a non-existent config file is specified" do
      expect { subject.tcfg_config_file 'fake.yml' }.to raise_error(TCFG::NoSuchConfigFileError)
      expect { subject.tcfg_secret_config_file 'fake.yml' }.to raise_error(TCFG::NoSuchConfigFileError)
    end

    it "should give a clear exception is non-existent key is requested" do
      expect { subject.tcfg_get 'fake_key' }.to raise_error(TCFG::NoSuchConfigurationKeyError)
    end
  end

  #retrieved config should always be immutable.  Changing it should not affect what comes out of further retrievals
  describe "tcfg immutablability" do
    before(:each) do
      subject.tcfg_config_file SAMPLE_CONFIG_FILE
    end

    it "should not change a simple string value" do
      retrieved_cfg = subject.tcfg
      retrieved_cfg['sample_string'] = 'myedit'
      subject.tcfg['sample_string'].should_not eql 'myedit'
    end

    it "should not change array value" do
      retrieved_cfg = subject.tcfg
      retrieved_cfg['sample_array'][0] = 'myedit'
      subject.tcfg['sample_array'][0].should_not eql 'myedit'
    end

    it "should not change an array value in a hash" do
      retrieved_cfg = subject.tcfg
      retrieved_cfg['sample_hash']['h_a'][0] = 'myedit'
      subject.tcfg['sample_hash']['h_a'][0].should_not eql 'myedit'
    end

  end
end

