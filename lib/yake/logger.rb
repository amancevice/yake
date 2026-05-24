# frozen_string_literal: true

require 'json'
require 'logger'

##
# Yake
module Yake
  ##
  # Yake Logger
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

    ##
    # Yake Logger Formatter
    class Formatter < ::Logger::Formatter
      Format = "%s %s %s\n" # rubocop: disable Naming/ConstantName

      def call(severity, _time, progname, msg)
        format(Format, severity, progname.nil? ? '-' : "RequestId: #{progname}", msg2str(msg).strip)
      end
    end
  end

  class << self
    attr_writer :logger, :pretty

    def logger  = @logger ||= Logger.new
    def pretty? = @pretty == true
  end
end
