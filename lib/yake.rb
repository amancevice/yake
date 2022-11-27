# frozen_string_literal: true

require_relative "yake/version"
require_relative "yake/logger"
require_relative "yake/errors"
require_relative "yake/dsl"

module Yake
  class << self
    attr_writer :logger, :pretty

    def logger
      @logger ||= Logger.new
    end

    def pretty?
      @pretty == true
    end

    def wrap(event = nil, context = nil, &block)
      original_progname = logger.progname
      logger.progname   = context&.aws_request_id
      jsonify           = -> (obj) { pretty? ? JSON.pretty_generate(obj) : obj.to_json }
      log_return        = -> (res) { logger.info("RETURN #{ jsonify === res }") }
      logger.info("EVENT #{ jsonify === event }")
      yield(event, context).tap(&log_return)
    ensure
      logger.progname = original_progname
    end
  end
end
