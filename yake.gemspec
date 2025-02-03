# frozen_string_literal: true

require_relative 'lib/yake/version'

Gem::Specification.new do |spec|
  spec.name    = 'yake'
  spec.version = Yake::VERSION
  spec.authors = ['Alexander Mancevice']
  spec.email   = ['alexander.mancevice@hey.com']

  spec.summary       = 'Rake-like DSL for declaring AWS Lambda function handlers'
  spec.homepage      = 'https://github.com/amancevice/yake'
  spec.license       = 'MIT'
  spec.require_paths = ['lib']
  spec.files         = Dir['README*', 'LICENSE*', 'lib/**/*']

  spec.required_ruby_version = '>= 3.2.0'
  spec.add_dependency 'ostruct'
  spec.add_dependency 'logger'
end
