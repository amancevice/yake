# frozen_string_literal: true

ENV['TZ'] = 'UTC'

require 'simplecov'
SimpleCov.start

require 'yake/api'
require 'yake/datadog'
require 'yake/support'

ENV['DD_ENHANCED_METRICS'] = '0'
case Datadog::Lambda::VERSION::MAJOR
when 1
  Datadog.configure { |c| c.tracer.enabled = false }
else
  Datadog.configure { |c| c.tracing.enabled = false }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
