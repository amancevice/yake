# frozen_string_literal: true

require "json"
require "logger"

module Yake
  module Logger
    attr_accessor :logger

    def logger
      @logger ||= Yake.logger
    end

    class << self
      def new(logdev = $stdout, **params)
        ::Logger.new(logdev, formatter: Formatter.new, **params)
      end
    end

    class Formatter < ::Logger::Formatter
      Format = "%s %s %s\n"

      def call(severity, time, progname, msg)
        Format % [ severity, progname.nil? ? "-" : "RequestId: #{ progname }", msg2str(msg).strip ]
      end
    end
  end

  class << self
    attr_accessor :logger

    def logger
      @logger ||= Logger.new
    end

    def wrap(event = nil, context = nil, &block)
      original_progname = logger.progname
      logger.progname = context&.aws_request_id
      logger.info("EVENT #{ event.to_json }")
      yield(event, context).tap { |res| logger.info("RETURN #{ res.to_json }") }
    ensure
      logger.progname = original_progname
    end
  end
end
