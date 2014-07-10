ENV["environment"] ||= 'test'
require "bundler/setup"

if ENV['COVERAGE'] and RUBY_VERSION =~ /^1.9/
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

require 'active-fedora'
require 'active_fedora_relsint'
require 'rspec'
require 'equivalent-xml/rspec_matchers'
logger.level = Logger::WARN if logger.respond_to? :level ###MediaShelf StubLogger doesn't have a level= method
$VERBOSE=nil

# This loads the Fedora and Solr config info from /config/fedora.yml
# You can load it from a different location by passing a file path as an argument.
def restore_spec_configuration
  ActiveFedora.init(:fedora_config_path=>File.join(File.dirname(__FILE__), "..", "config", "fedora.yml"))
end
restore_spec_configuration

RSpec.configure do |config|
  config.color = true
end

def fixture(file)
  File.open(File.join(File.dirname(__FILE__), '..','fixtures', file), 'rb')
end
