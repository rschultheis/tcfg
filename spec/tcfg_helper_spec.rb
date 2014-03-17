include TCFG::Helper

describe TCFG::Helper do
  it "should support configuration using a block" do
    tcfg_set :browser, 'firefox'

    tcfg_get(:browser).should eql 'firefox'
  end
end
