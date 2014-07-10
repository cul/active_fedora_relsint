require 'spec_helper'

describe ActiveFedora::RelsInt do
  before :all do
    class Foo < ActiveFedora::Base
      include ActiveFedora::RelsInt
    end
  end
  
  after :all do
    Object.send(:remove_const, :Foo) # cleanup
  end
  
  describe "modules" do
    it "should exist" do
      expect(defined? ActiveFedora::RelsInt).to be_truthy
      expect(defined? ActiveFedora::RelsInt::Datastream).to be_truthy
    end
  end

  it "should add the appropriate ds_spec and accessor methods when mixed in" do
    expect(Foo.ds_specs.keys).to include( 'RELS-INT')
    expect(Foo.ds_specs['RELS-INT'][:type]).to be(ActiveFedora::RelsInt::Datastream)
  end

  it "should serialize to appropriate RDF-XML on a new object" do
    blank_relsint = fixture('rels_int_blank.xml').read
    inner = double("DigitalObject")
    allow(inner).to receive(:new_record?).and_return(true)
    allow(inner).to receive(:pid).and_return("test:relsint")
    repo = double("Repository")
    allow(inner).to receive(:repository).and_return(repo)
    test_obj = ActiveFedora::RelsInt::Datastream.new(inner,"RELS-INT")
    expect(Nokogiri::XML.parse(test_obj.content)).to be_equivalent_to Nokogiri::XML.parse(blank_relsint)
  end
  
  it "should serialize to appropriate RDF-XML when added to an existing obect" do
    blank_relsint = fixture('rels_int_blank.xml').read
    inner = double("DigitalObject")
    allow(inner).to receive(:new_record?).and_return(false)
    allow(inner).to receive(:pid).and_return("test:relsint")
    repo = double("Repository")
    # new datastream, no profile
    expect(repo).to receive(:datastream_profile).with(inner.pid,"RELS-INT",nil, nil).and_return('')
    allow(inner).to receive(:repository).and_return(repo)
    test_obj = ActiveFedora::RelsInt::Datastream.new(inner,"RELS-INT")
    expect(Nokogiri::XML.parse(test_obj.content)).to be_equivalent_to Nokogiri::XML.parse(blank_relsint)
  end

  describe ActiveFedora::RelsInt::Datastream do
    before :each do
      @test_relsint = fixture('rels_int_test.xml').read
      @inner = double("DigitalObject")
      allow(@inner).to receive(:new_record?).and_return(false)
      allow(@inner).to receive(:pid).and_return("test:relsint")
      allow(@inner).to receive(:internal_uri).and_return("info:fedora/test:relsint")
      repo = double("Repository")
      profile_xml = fixture('rels_int_profile.xml').read
      profile = Rubydora::ProfileParser.parse_datastream_profile(profile_xml)
      expect(repo).to receive(:datastream_profile).with(@inner.pid,"RELS-INT",nil, nil).and_return(profile)
      allow(repo).to receive(:datastream_dissemination).with(:pid=>@inner.pid,:dsid=>"RELS-INT").and_return(@test_relsint)
      allow(@inner).to receive(:repository).and_return(repo)
    end
    it "should load relationships from foxml into the appropriate graphs" do
      test_obj = ActiveFedora::RelsInt::Datastream.new(@inner,"RELS-INT")
      expect(test_obj.changed?).to be(false)
      dc = ActiveFedora::Datastream.new(@inner,"DC")
      triples = test_obj.relationships(dc,:is_metadata_for)
      e = ['info:fedora/test:relsint/DC','info:fedora/fedora-system:def/relations-external#isMetadataFor','info:fedora/test:relsint/RELS-INT'].
        map {|x| RDF::URI.new(x)}
      f = ['info:fedora/test:relsint/DC','info:fedora/fedora-system:def/relations-external#isMetadataFor','info:fedora/test:relsint/RELS-EXT']
        .map {|x| RDF::URI.new(x)}
      expect(triples).to eq([RDF::Statement.new(*e),RDF::Statement.new(*f)])
      expect(Nokogiri::XML.parse(test_obj.content)).to be_equivalent_to Nokogiri::XML.parse(@test_relsint)
    end
    it "should load relationships into appropriate graphs when assigned content" do
      #test_relsint = fixture('rels_int_test.xml').read
      #inner = double("DigitalObject")
      #inner.stub(:pid).and_return("test:relsint")
      #inner.stub(:internal_uri).and_return("info:fedora/test:relsint")
      test_obj = ActiveFedora::RelsInt::Datastream.new(@inner,"RELS-INT")
      test_obj.content=@test_relsint
      expect(test_obj.changed?).to be(true)
      dc = ActiveFedora::Datastream.new(@inner,"DC")
      triples = test_obj.relationships(dc,:is_metadata_for)
      e = ['info:fedora/test:relsint/DC','info:fedora/fedora-system:def/relations-external#isMetadataFor','info:fedora/test:relsint/RELS-INT']
        .map {|x| RDF::URI.new(x)}
      f = ['info:fedora/test:relsint/DC','info:fedora/fedora-system:def/relations-external#isMetadataFor','info:fedora/test:relsint/RELS-EXT']
        .map {|x| RDF::URI.new(x)}
      expect(triples).to eq([RDF::Statement.new(*e),RDF::Statement.new(*f)])
    end    
    it "should propagate relationship changes to the appropriate graph in RELS-INT" do
      #test_relsint = fixture('rels_int_test.xml').read
      #inner = double("DigitalObject")
      #inner.stub(:pid).and_return("test:relsint")
      #inner.stub(:internal_uri).and_return("info:fedora/test:relsint")
      test_obj = ActiveFedora::RelsInt::Datastream.new(@inner,"RELS-INT")
      dc = ActiveFedora::Datastream.new(@inner,"DC")
      rels_ext = ActiveFedora::Datastream.new(@inner,"RELS-EXT")
      expect(test_obj.to_resource(test_obj)).to eql(RDF::URI.new("info:fedora/#{@inner.pid}/#{test_obj.dsid}"))
      test_obj.add_relationship(dc,:is_metadata_for, test_obj)
      test_obj.add_relationship(dc,:is_metadata_for, rels_ext)
      test_obj.add_relationship(rels_ext,:asserts, "FOO", true)
      test_obj.add_relationship(test_obj,:asserts, "BAR", true)
      test_obj.serialize!
      expect(Nokogiri::XML.parse(test_obj.content)).to be_equivalent_to Nokogiri::XML.parse(@test_relsint)
    end
    it "should run to_solr" do
      test_obj = ActiveFedora::RelsInt::Datastream.new(@inner,"RELS-INT")
      test_obj.content=@test_relsint
      expect(test_obj.changed?).to be(true)
      expect{test_obj.to_solr}.to_not raise_error
    end
  end
  

  pending "should load from solr" do
    f = Foo.create
    Foo.load_instance_from_solr(f.id).should_not be_nil
  end
end
