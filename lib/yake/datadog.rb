# frozen_string_literal: true

require 'logger'

require 'datadog/lambda'
require 'yake'

##
# Yake
module Yake
  module Datadog
    ##
    # Datadog Logger Formatter
    class Formatter < ::Logger::Formatter
      Format = "[%s] %s %s %s %s\n" # rubocop: disable Naming/ConstantName

      def call(severity, time, progname, msg)
        format(Format, severity, time.utc.strftime('%Y-%m-%dT%H:%M:%S.%LZ'), progname.nil? ? '-' : progname.split.last,
               ::Datadog::Tracing.log_correlation, msg2str(msg).strip)
      end
    end

    ##
    # Mock Lambda Context
    MockContext = Struct.new(
      :clock_diff,
      :deadline_ms,
      :aws_request_id,
      :invoked_function_arn,
      :log_group_name,
      :log_stream_name,
      :function_name,
      :memory_limit_in_mb,
      :function_version
    ) do
      def invoked_function_arn
        @invoked_function_arn ||= begin
          region = ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'] || 'us-east-1'
          "arn:aws:lambda:#{region}:123456789012:function-name"
        end
      end
    end

    ##
    # Datadog DSL
    module DSL
      include Yake::DSL

      ##
      # Datadog handler wrapper
      def datadog(name, &block)
        define_method(name) do |event: nil, context: nil|
          context ||= MockContext.new
          ::Datadog::Lambda.wrap(event, context) do
            Yake.wrap(event, context, &block)
          end
        end
      end
    end
  end

  logger.formatter = Datadog::Formatter.new
end

extend Yake::Datadog::DSL # rubocop: disable Style/MixinUsage
