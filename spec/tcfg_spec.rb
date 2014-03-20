describe TCFG do

  before(:each) do
    @tcfg = TCFG::Base.new
  end

  describe "Each of the tiers" do

  end
  it "should support defining from code" do
    @tcfg.tcfg_set 'browser', :firefox
    @tcfg.tcfg_get(:browser).should eql :firefox
    @tcfg.tcfg_get('browser').should eql :firefox
  end

  describe "misc stuff" do
    it "should throw warning if private method called" do
      expect {
        @tcfg.tcfg_code_defaults
      }.to raise_error(NoMethodError)
    end
  end
end
