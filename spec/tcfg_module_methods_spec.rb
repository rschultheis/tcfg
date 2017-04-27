describe TCFG do

 context "working directory has tcfg.yml and tcfg.secret.yml" do
  before(:each) do
   @orig_working_dir = Dir.pwd
   Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
   subject.tcfg_reset
  end
  after(:each) do
   Dir.chdir @orig_working_dir
  end

  it { subject.tcfg.should include 'sample_string' }

  it { subject.tcfg_get('sample_float').should == 1.23 }

  it "should support the [] operators directly" do
   TCFG['sample_string'].should eql 'sample_string_value_from_default_file'
  end
 end

 it "should support tcfg_set and tcfg_get" do
  subject.tcfg_set 'a new value', 'xxxyyy'
  subject.tcfg_get('a new value').should == 'xxxyyy'
 end

end

