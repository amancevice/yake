# frozen_string_literal: true

require "json"

require_relative "logger"

module Yake
  module DSL
    ##
    # Lambda handler task wrapper
    def handler(name, &block)
      define_method(name) do |event:nil, context:nil|
        Yake.logger.wrap(event, context, &block)
      end
    end
  end
end

extend Yake::DSL
