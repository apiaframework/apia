# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }
gemspec

group :development, :test do
  gem 'appraisal'
  gem 'pry'
  gem 'rake'
  gem 'rspec'
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'rubocop'
  gem 'ruby-lsp-rspec', require: false if RUBY_VERSION >= '3.0'
end
