SAMPLE_CONFIG_FILE = File.expand_path('../sample_configs/sample1.yml', __FILE__)
SAMPLE_SECRET_CONFIG_FILE = File.expand_path('../sample_configs/sample1x.secret.yml', __FILE__)

describe TCFG::Helper do

  let(:dummy_class) do 
    anon_class = Class.new { include TCFG::Helper }
    anon_class.new
  end

  after(:each) do
    ENV.delete_if {|k| k =~ /^TCFG_/ }
  end

  describe "each config tier independently" do
    it "should support configuration from code using set method" do
      dummy_class.instance_eval do

        tcfg_set :browser, 'firefox'
        tcfg_get(:browser).should == 'firefox'

        tcfg['browser'].should == 'firefox'
      end
    end

    it "support picking up configuration from a config file" do
      dummy_class.instance_eval do

        tcfg_config_file SAMPLE_CONFIG_FILE
        tcfg.keys.include?('sample_string').should == true
        tcfg['sample_string'].should == 'sample_string_value'

      end
    end

    it "support picking up configuration from a secret config file" do
      dummy_class.instance_eval do

        tcfg_secret_config_file SAMPLE_SECRET_CONFIG_FILE
        tcfg.keys.include?('sample_secret_username').should == true
        tcfg['sample_secret_username'].should == 'this_is_a_username'

      end
    end

    it "should support overriding based on environment variables prefixed with TCFG_" do
      ENV['TCFG_sample_string'] = 'overridden'
      dummy_class.instance_eval do

        tcfg_config_file SAMPLE_CONFIG_FILE

        tcfg['sample_string'].should == 'overridden'

      end
    end
  end

  #TODO: changing the config file should forget any config from old file
  #TODO: retrieved config should always be immutable.  Changing it should not affect what comes out of further retrievals

end
