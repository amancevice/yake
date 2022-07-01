# frozen_string_literal: true

require 'json'
require 'logger'

module Yake
  module Logger
    attr_writer :logger

    def logger
      @logger ||= Yake.logger
    end

    class << self
      def new(logdev = $stderr, **params)
        ::Logger.new(logdev, formatter: Formatter.new, **params)
      end
    end

    class Formatter < ::Logger::Formatter
      Format = "%s %s %s\n"

      def call(severity, time, progname, msg)
        Format % [ severity, progname.nil? ? '-' : "RequestId: #{ progname }", msg2str(msg).strip ]
      end
    end
  end

  class << self
    attr_writer :logger, :pretty

    def logger
      @logger ||= Logger.new
    end

    def pretty?
      @pretty != false
    end

    def wrap(event = nil, context = nil, &block)
      original_progname = logger.progname
      logger.progname   = context&.aws_request_id
      jsonify           = -> (obj) { pretty? ? JSON.pretty_generate(obj) : obj.to_json }
      logger.info("EVENT #{ jsonify === event }")
      yield(event, context).tap do |res|
        logger.info("RETURN #{ jsonify === res }")
      end
    ensure
      logger.progname = original_progname
    end
  end
end
