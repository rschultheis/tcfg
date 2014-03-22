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

  describe "calling class methods right off the module" do
    it "it should act as a singleton" do
      Dir.chdir File.join(@orig_working_dir, 'spec/sample_configs')
      TCFG.tcfg['sample_string'].should == 'sample_string_value_from_default_file'

      TCFG.tcfg_set 'a new value', 'xxxyyy'
      TCFG.tcfg_get('a new value').should == 'xxxyyy'
    end
  end

end

