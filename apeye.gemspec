# frozen_string_literal: true

require_relative './lib/moonstone/version'
Gem::Specification.new do |s|
  s.name          = 'moonstone'
  s.description   = 'A framework for building REST APIs.'
  s.summary       = 'This gem provides a friendly DSL for constructing REST APIs.'
  s.homepage      = 'https://github.com/krystal/moonstone'
  s.version       = Moonstone::VERSION
  s.files         = Dir.glob('{lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@k.io']
  s.add_runtime_dependency 'rack'
end
