# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'studitemps/utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'studitemps-utils'
  spec.version       = Studitemps::Utils::VERSION
  spec.authors       = ['Studitemps']
  spec.email         = ['developers@studitemps.de']

  spec.summary       = 'Studitemps utils.'
  spec.description   = 'Shared utils for Studitemp\'s Ruby projects.'
  spec.homepage      = 'https://tech.studitemps.de'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/STUDITEMPS/utils'
  spec.metadata['changelog_uri'] = 'https://github.com/STUDITEMPS/utils/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-core', '~> 1.0'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.3.0'
  spec.add_runtime_dependency 'dry-initializer', '~> 3.2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
