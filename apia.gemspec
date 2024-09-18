# frozen_string_literal: true

require_relative 'lib/apia/version'

Gem::Specification.new do |s|
  s.name          = 'apia'
  s.description   = 'A framework for building HTTP APIs.'
  s.summary       = 'This gem provides a friendly DSL for constructing HTTP APIs.'
  s.homepage      = 'https://github.com/krystal/apia'
  s.version       = Apia::VERSION
  s.files         = Dir.glob('VERSION') + Dir.glob('{lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@k.io']
  s.licenses      = ['MIT']
  s.add_dependency 'json'
  s.add_dependency 'rack'
end
