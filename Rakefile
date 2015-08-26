require 'rake/clean'
require 'rubygems'
require 'bundler'
require "bundler/setup"
require "active_fedora_relsint"

Bundler::GemHelper.install_tasks

# load rake tasks defined in lib/tasks that are not loaded in lib/active_fedora.rb
load "lib/tasks/active_fedora_relsint_dev.rake" if defined?(Rake)

CLEAN.include %w[**/.DS_Store tmp *.log *.orig *.tmp **/*~]

task :spec => ['active_fedora_relsint:rspec']
task :rcov => ['active_fedora_relsint:rcov']


task :default => [:ci]