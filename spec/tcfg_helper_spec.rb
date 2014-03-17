include TCFG::Helper

describe TCFG::Helper do
  it "should support configuration using a block" do
    set :browser, 'firefox'

    get(:browser).should eql 'firefox'
  end
end
