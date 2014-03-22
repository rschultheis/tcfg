describe TCFG::Helper do

  let(:dummy_class) do 
    anon_class = Class.new { include TCFG::Helper }
    anon_class.new
  end

  #these specs involve changing around the working directory
  #to pick up tcfg.yml / tcfg.secret.yml by default
  before(:each) do
    @orig_working_dir = Dir.pwd
  end

  after(:each) do
    Dir.chdir @orig_working_dir
  end

  describe "defaulting config file name" do
    it "it should find tcfg.yml and tcfg.secret.yml in working dir if present without any special calls" do
      Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
      dummy_class.instance_eval do
        #from tcfg.yml
        tcfg['sample_string'].should == 'sample_string_value_from_default_file'

        #from tcfg.secret.yml
        tcfg['sample_secret_username'].should == 'this_is_a_username'
      end
    end

  end

  #TODO: changing the config file should forget any config from old file
  #TODO: retrieved config should always be immutable.  Changing it should not affect what comes out of further retrievals
  #TODO: any TCFG_ environment variable must be pre-defined in config file or code (cant override what doesnt exist)
  #TODO: config file does not exist
  #TODO: using TCFG as a singleton
end
