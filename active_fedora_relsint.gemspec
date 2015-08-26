# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_fedora_relsint/version"

Gem::Specification.new do |s|
  s.name        = "active_fedora_relsint"
  s.version     = ActiveFedora::RelsInt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Benjamin Armintor"]
  s.email       = ["armintor@gmail.com"]
  s.homepage    = %q{https://github.com/cul/active_fedora_rels_int}
  s.summary     = %q{ActiveFedora library supporting RELS-INT datastreams}
  s.description     = %q{ActiveFedora library to allow use of RELS-INT to track RDF assertions about datastreams via a similar api to the ActiveFedora RELS-EXT implementation}

  s.rubygems_version = %q{1.3.7}

  s.add_dependency('active-fedora', '~> 7.0')
  s.add_dependency("activesupport", '>= 3.2.0', "< 5.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("RedCloth") # for RDoc formatting
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", ">= 2.9.0")
  s.add_development_dependency("mediashelf-loggable")
  s.add_development_dependency "jettywrapper", ">=1.4.0"
  s.add_development_dependency("simplecov")
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.textile"
  ]
  s.require_paths = ["lib"]

end
