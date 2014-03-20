SAMPLE_CONFIG_FILE = File.expand_path('../sample_configs/sample1.yml', __FILE__)

describe TCFG::Helper do

  let(:dummy_class) do 
    anon_class = Class.new { include TCFG::Helper }
    anon_class.new
  end

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

  it "should support overriding based on environment" do
    ENV['sample_string'] = 'overridden'
    dummy_class.instance_eval do

      tcfg_config_file SAMPLE_CONFIG_FILE

      tcfg['sample_string'].should == 'overridden'

    end
    ENV['sample_string'] = nil
  end




  #retrieved config should always be immutable.  Changing it should not affect what comes out of further retrievals


end
