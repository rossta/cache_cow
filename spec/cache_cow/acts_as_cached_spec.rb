require 'spec_helper'

describe CacheCow::ActsAsCached do

  it "should be a module" do
    CacheCow::ActsAsCached.should be_kind_of(Module)
  end
end
