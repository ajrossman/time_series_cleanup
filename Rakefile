# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "time_series_cleanup"
  gem.homepage = "http://github.com/ajrossman/time_series_cleanup"
  gem.license = "All rights reserved by Smart Resource Institute"
  gem.summary = %Q{utilities to cleanup time-series data sets}
  gem.description = %Q{utilities to cleanup time-series data sets}
  gem.email = "aj@smartresourceinstitute.com"
  gem.authors = ["ajrossman"]
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "time_series_cleanup #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
