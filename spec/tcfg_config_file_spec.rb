describe TCFG::Helper do

  subject { Class.new { include TCFG::Helper }.new }

  #these specs involve changing around the working directory
  #to pick up tcfg.yml / tcfg.secret.yml by default
  before(:each) do
    @orig_working_dir = Dir.pwd
  end

  after(:each) do
    Dir.chdir @orig_working_dir
  end

  context "working directory has tcfg.yml and tcfg.secret.yml" do
    before(:each) do
      Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
    end

    it "it should find tcfg.yml and tcfg.secret.yml in working dir if present without any special calls" do
      subject.instance_eval do
        #from tcfg.yml
        tcfg['sample_string'].should == 'sample_string_value_from_default_file'

        #from tcfg.secret.yml
        tcfg['sample_secret_username'].should == 'this_is_a_username'
      end
    end
  end

  context "working directory has tcfg.yml and tcfg.secret.yml, but are overriding config file name" do
    before(:each) do
      Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
      subject.tcfg_config_file 'sample1.yml'
    end

    it "should pickup the specified config file and ignore the default one" do
      subject.tcfg['sample_string'].should == 'sample_string_value'
    end
  end
end
