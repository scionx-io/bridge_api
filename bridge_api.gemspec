# frozen_string_literal: true

require File.expand_path('lib/bridge_api/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'bridge_api'
  spec.version               = BridgeApi::VERSION
  spec.authors               = ['Bolo Michelin']
  spec.email                 = ['bolo@scionx.io']

  spec.summary               = 'Ruby gem for Bridge.xyz API integration'
  spec.description           = 'A Ruby gem that provides easy access to the Bridge.xyz API for ' \
                               'financial services integration, supporting both sandbox and production environments.'
  spec.homepage              = 'https://github.com/ScionX/bridge_api'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 3.2.0'

  # List of files to include in the gem
  spec.files = Dir['README.md', 'LICENSE.md', 'CHANGELOG.md', 'example.rb', 'lib/**/*.rb', 'exe/**/*',
                   'bridge_api.gemspec', 'Gemfile', 'Rakefile']

  spec.extra_rdoc_files = ['README.md', 'CHANGELOG.md', 'LICENSE.md']

  # Runtime dependencies
  spec.add_dependency 'httparty', '~> 0.20'
  spec.add_dependency 'json', '~> 2.6'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
