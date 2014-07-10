# -*- encoding : utf-8 -*-
require 'active_support'
module ActiveFedora
  module RelsInt
    extend ActiveSupport::Concern
    autoload :RDFXMLWriter, 'active_fedora_relsint/rdf_xml_writer'
    autoload :Datastream, 'active_fedora_relsint/datastream'
    included do
      self.has_metadata :name=>"RELS-INT", :type=>ActiveFedora::RelsInt::Datastream
    end
    
    def rels_int
      if !datastreams.has_key?("RELS-INT")
        ds = ActiveFedora::RelsInt::Datastream.new(@inner_object, "RELS-INT")
        add_datastream(ds)
      end
      return datastreams["RELS-INT"]
    end
  end
end
require 'active_fedora_relsint/version'