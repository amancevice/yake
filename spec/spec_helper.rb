# frozen_string_literal: true

ENV['TZ'] = 'UTC'

require 'simplecov'
SimpleCov.start

require 'base64'

require 'yake/api'
require 'yake/datadog'
require 'yake/support'

ENV['DD_LOG_LEVEL'] = 'WARN'
Datadog.configure { |c| c.tracing.enabled = true }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
