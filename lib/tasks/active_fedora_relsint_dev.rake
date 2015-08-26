APP_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../../")
require 'jettywrapper'
JETTY_ZIP_BASENAME = '7.x-stable'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"
namespace :active_fedora_relsint do
  require 'active-fedora'

  # Use yard to build docs
  begin
    require 'yard'
    require 'yard/rake/yardoc_task'
    project_root = APP_ROOT
    doc_destination = File.join(project_root, 'doc')

    YARD::Rake::YardocTask.new(:doc) do |yt|
      yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                   [ File.join(project_root, 'README.textile')]
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.textile']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :doc do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:rspec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
    spec.pattern += FileList['spec/*_spec.rb']
  end

  RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
    spec.pattern += FileList['spec/*_spec.rb']
    spec.rcov = true
  end

desc "Execute specs with coverage"
task :coverage do 
  # Put spec opts in a file named .rspec in root
  ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby"
  ENV['COVERAGE'] = 'true' unless ruby_engine == 'jruby'

  Rake::Task["active_fedora_relsint:rspec"].invoke
end

end

desc "CI build"
task ci: 'jetty:unzip' do
  ENV['environment'] = "test"
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['active_fedora_relsint:coverage'].invoke
  end
  raise "test failures: #{error}" if error
end