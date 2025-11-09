# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    warn 'RuboCop is disabled'
  end
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task default: %i[test rubocop]
