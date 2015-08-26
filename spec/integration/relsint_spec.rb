require 'spec_helper'

describe ActiveFedora::RelsInt, type: :integration do
  before :all do
    class Foo < ActiveFedora::Base
      include ActiveFedora::RelsInt
    end
  end
  
  after :all do
    Object.send(:remove_const, :Foo) # cleanup
  end

  it "should load from solr" do
    f = Foo.create
    Foo.load_instance_from_solr(f.id).should_not be_nil
  end
end