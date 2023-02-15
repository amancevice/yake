# frozen_string_literal: true

require 'json'

require_relative 'logger'

module Yake
  module DSL
    ##
    # Lambda handler task wrapper
    def handler(name, &block)
      define_method(name) do |event:nil, context:nil|
        Yake.wrap(event, context, &block)
      end
    end

    ##
    # Helper to get logger
    def logger
      Yake.logger
    end

    ##
    # Turn logging on/off
    def logging(switch = :on, logger = nil, pretty: false)
      Yake.pretty = pretty
      if switch == :on
        Yake.logger = logger
      elsif switch == :off
        Yake.logger = ::Logger.new(nil)
      else
        raise Errors::UnknownLoggingSetting, switch
      end
    end
  end

  class << self
    def wrap(event = nil, context = nil, &block)
      original_progname = logger.progname
      logger.progname   = context&.aws_request_id
      jsonify           = -> (obj) { pretty? ? JSON.pretty_generate(obj) : obj.to_json }
      log_return        = -> (res) { logger.info("RETURN #{ jsonify === res }") }
      logger.info("EVENT #{ jsonify === event }")
      (yield(event, context) if block_given?).tap(&log_return)
    ensure
      logger.progname = original_progname
    end
  end
end

extend Yake::DSL
