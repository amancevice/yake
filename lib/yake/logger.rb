# frozen_string_literal: true

require "json"
require "logger"

module Yake
  class Logger < ::Logger
    def initialize(logdev = $stdout, *)
      super
      @progname  = "-"
      @formatter = LambdaFormatter.new
    end

    def wrap(event = nil, context = nil, &block)
      @progname = "RequestId: #{ context.aws_request_id }" if context.respond_to?(:aws_request_id)
      info("EVENT #{ event.to_json }")
      yield(event, context).tap { |res| info("RETURN #{ res.to_json }") }
    ensure
      @progname = "-"
    end
  end

  class LambdaFormatter < ::Logger::Formatter
    Format = "%s %s %s\n"

    def call(severity, time, progname, msg)
      Format % [ severity, progname, msg2str(msg).strip ]
    end
  end

  module Loggable
    attr_accessor :logger
  end

  extend Loggable
end
