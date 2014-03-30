describe TCFG::Base do

  subject { described_class.new }

  it "should support defining from code" do
    subject.tcfg_set 'browser', :firefox
    subject.tcfg_get(:browser).should eql :firefox
    subject.tcfg_get('browser').should eql :firefox
    subject.tcfg.should eql({ 'browser' => :firefox })
  end

  it "should pickup the config file from the working directory" do
    @orig_working_dir = Dir.pwd
    Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
    subject.tcfg.should include "sample_array", "sample_integer"
    Dir.chdir @orig_working_dir
  end

  it "should not allow accessing tiers directly" do
    expect {
      subject.tier_code_defaults
    }.to raise_error(NoMethodError)
  end
end

#TODO: any TCFG_ environment variable must be pre-defined in config file or code (cant override what doesnt exist)
#TODO: config file does not exist
#TODO: using TCFG as a singleton
#TODO: changing the config file should forget any config from old file
