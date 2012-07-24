require 'spec_helper'

describe ActiveFedora::RelsInt do
  before :all do
    class Foo < ActiveFedora::Base
      include ActiveFedora::RelsInt
    end
  end
  
  describe "modules" do
    it "should exist" do
      (defined? ActiveFedora::RelsInt).should be_true
      (defined? ActiveFedora::RelsInt::Datastream).should be_true
      (defined? ActiveFedora::RelsInt::SemanticNode).should be_true
    end
  end

  it "should add the appropriate ds_spec and accessor methods when mixed in" do
    Foo.ds_specs.keys.should include 'RELS-INT'
    Foo.ds_specs['RELS-INT'][:type].should == ActiveFedora::RelsInt::Datastream
  end

  it "should serialize to appropriate RDF-XML" do
    blank_relsint = fixture('rels_int_blank.xml').read
    Nokogiri::XML.parse(Foo.new.relsint.content).should be_equivalent_to Nokogiri::XML.parse(blank_relsint)
  end
  
  describe Datastream do
    it "should load relationships from foxml into the appropriate graphs" do
      pending "mocking the fcrepo responses"
    end
    it "should load relationships into appropriate graphs when assigned content" do
      test_relsint = fixture('rels_int_test.xml').read
      test_obj = Foo.new
      test_obj.relsint.content = test_relsint
      strings = test_obj.dc.relationships(:is_metadata_for).map {|x| x.to_s}
      strings.should == ['info:fedora/__DO_NOT_USE__']
    end
  end
  describe SemanticNode do
    it "should have been included by all datastreams of a model mixing-in ActiveFedora::RelsInt" do
      test_obj = Foo.new
      (test_obj.dc.is_a? ActiveFedora::RelsInt::SemanticNode).should be_true
      new_ds = test_obj.create_datastream("NEW", ActiveFedora::Datastream)
      test_obj.add_datastream(new_ds)
      (new_ds.is_a? ActiveFedora::RelsInt::SemanticNode).should be_true
    end
    
    it "should propagate relationship changes to the appropriate graph in RELS-INT" do
      test_relsint = fixture('rels_int_test.xml').read
      test_obj = Foo.new
      test_obj.dc.add_relationship(:is_metadata_for, test_obj)
      test_obj.relsext.add_relationship(:asserts, "FOO", true)
      test_obj.relsint.add_relationship(:asserts, "BAR", true)
      Nokogiri::XML.parse(test_obj.relsint.content).should be_equivalent_to Nokogiri::XML.parse(test_relsint)
    end
  end
end