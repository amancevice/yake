# frozen_string_literal: true

require 'datadog/lambda'
require 'yake'

module Yake
  module Datadog
    class MockContext < Struct.new(
      :clock_diff,
      :deadline_ms,
      :aws_request_id,
      :invoked_function_arn,
      :log_group_name,
      :log_stream_name,
      :function_name,
      :memory_limit_in_mb,
      :function_version)

      def invoked_function_arn
        @invoked_function_arn ||= begin
          region = ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-east-1'
          "arn:aws:lambda:#{region}:123456789012:function-name"
        end
      end
    end

    module DSL
      include Yake::DSL

      ##
      # Datadog handler wrapper
      def datadog(name, &block)
        define_method(name) do |event:nil, context:nil|
          context ||= MockContext.new
          ::Datadog::Lambda.wrap(event, context) do
            Yake.wrap(event, context, &block)
          end
        end
      end
    end
  end
end

extend Yake::Datadog::DSL
