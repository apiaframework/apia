# frozen_string_literal: true

require_relative './lib/apeye/version'
Gem::Specification.new do |s|
  s.name          = 'apeye'
  s.description   = 'A framework for building REST APIs.'
  s.summary       = 'This gem provides a friendly DSL for constructing REST APIs.'
  s.homepage      = 'https://github.com/krystal/apeye'
  s.version       = APeye::VERSION
  s.files         = Dir.glob('{lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@k.io']
end
