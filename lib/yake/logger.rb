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
        Format % [
          severity,
          progname.nil? ? '-' : "RequestId: #{ progname }",
          msg2str(msg).strip
        ]
      end
    end
  end

  class << self
    attr_writer :logger, :pretty

    def logger  = @logger ||= Logger.new
    def pretty? = @pretty == true
  end
end
