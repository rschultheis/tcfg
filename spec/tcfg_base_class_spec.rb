describe TCFG::Base do

 subject { described_class.new }

 context 'working directory has tcfg.yml and tcfg.secret.yml' do
  before(:each) do
   @orig_working_dir = Dir.pwd
   Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
   subject.tcfg_set 'run_mode', :fast
  end
  after(:each) do
   Dir.chdir @orig_working_dir
  end

  it 'should support [] operator for retrieving config' do
   subject['sample_integer'].should eql 123
  end

  it 'should support using tcfg_get' do
   subject.tcfg_get('run_mode').should eql :fast
   subject.tcfg_get(:sample_float).should eql 1.23
  end

  it 'should pickup the config file from the working directory' do
   subject.tcfg.should include 'sample_array', 'sample_integer'
  end

  it 'should not allow accessing tiers directly' do
   expect {
    subject.tier_code_defaults
   }.to raise_error(NoMethodError)
  end
 end
end

