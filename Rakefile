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

begin
  require 'bundler/audit/task'
  Bundler::Audit::Task.new
rescue LoadError
  namespace :bundle do
    task :audit do
      warn 'bundler-audit is disabled'
    end
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb']
    t.options = ['--output-dir', 'doc', '--markup', 'markdown']
  end
rescue LoadError
  task :yard do
    warn 'YARD is disabled'
  end
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task default: %i[test rubocop bundle:audit]
