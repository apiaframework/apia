# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: :spec
task test: :spec
task lint: :rubocop

# rubocop:disable Metrics/BlockLength
task :tag do
  last_tag = `git tag`.split(/\n/).select { |t| t =~ /\Av/ }.map { |t| Gem::Version.new(t.sub(/\Av/, '')) }.max || 'none'
  last_tag = 'v' + last_tag.to_s if last_tag

  begin
    $stdout.print "Enter the version number that you wish to release (last: #{last_tag || 'n/a'}): \e[34mv"
    version = $stdin.gets.strip
  ensure
    $stdout.print "\e[0m"
  end

  unless system("git tag v#{version}")
    puts 'Could not create tag!'
    exit 1
  end

  unless system("git push origin v#{version}")
    puts 'Failed to push tag to origin'
    exit 1
  end

  gemspec_path = Dir[File.join(__dir__, '*.gemspec')].first
  if gemspec_path.nil?
    puts 'No gemspec found in the root of the project.'
    exit 0
  end

  require 'rubygems'
  spec = Gem::Specification.load(gemspec_path)
  unless spec.homepage =~ /\Ahttps\:\/\/github\./
    puts 'Homepage in the gemspec is not a GitHub repository.'
    exit 0
  end

  homepage = spec.homepage.sub(/\/*\z/, '')
  puts
  puts "\e[32mTag v#{version} pushed successfully.\e[0m"
  puts
  puts "The following URLS may be useful to check what's happening now..."
  puts
  puts "  📦 Package list: #{homepage}/packages"
  puts "  🐄 Releases:     #{homepage}/releases"
  puts "  🚧 Actions:      #{homepage}/actions"
  puts "  🌳 Browse tree:  #{homepage}/tree/v#{version}"
  puts
  true
end
# rubocop:enable Metrics/BlockLength
