# frozen_string_literal: true

require "json"

require_relative "logger"

module Yake
  module DSL
    ##
    # Lambda handler task wrapper
    def handler(name, &block)
      define_method(name) do |event:nil, context:nil|
        Yake.logger.nil? ? yield(event, context) : Yake.logger.wrap(event, context, &block)
      end
    end

    ##
    # Turn logging on/off
    def logging(switch, logdev = $stdout, **options)
      if switch == :on
        Yake.logger = Yake::Logger.new(logdev)
      elsif switch == :off
        Yake.logger = Yake::Logger.new(nil)
      else
        raise Errors::UnknownLoggingSetting, switch
      end
    end
  end
end

extend Yake::DSL
Yake.logger = Yake::Logger.new
