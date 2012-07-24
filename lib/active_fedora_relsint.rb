require 'active_support'
module ActiveFedora
  module RelsInt
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :Datastream
      autoload :SemanticNode
    end
  end
end
require 'active_fedora_relsint/version'