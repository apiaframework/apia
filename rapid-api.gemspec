# frozen_string_literal: true

require_relative './lib/rapid/version'

Gem::Specification.new do |s|
  s.name          = 'rapid-api'
  s.description   = 'A framework for building HTTP APIs.'
  s.summary       = 'This gem provides a friendly DSL for constructing HTTP APIs.'
  s.homepage      = 'https://github.com/krystal/rapid'
  s.version       = Rapid::VERSION
  s.files         = Dir.glob('{lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@k.io']
  s.add_runtime_dependency 'rack'
end
