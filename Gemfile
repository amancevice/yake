# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :test do
  gem 'pry',       '~> 0.14'
  gem 'rake',      '~> 13.1'
  gem 'rspec',     '~> 3.12', require: 'rspec/core/rake_task'
  gem 'simplecov', '~> 0.22'
end

group :datadog do
  gem 'ddtrace'
  gem 'datadog-lambda'
  gem 'rexml'
end
