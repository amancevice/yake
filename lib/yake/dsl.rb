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
    def logging(switch = :on, logger = nil, pretty: true)
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
end

extend Yake::DSL
