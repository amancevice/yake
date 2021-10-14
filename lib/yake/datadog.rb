# frozen_string_literal: true

require 'datadog/lambda'
require 'yake'

module Yake
  module Datadog
    module DSL
      include Yake::DSL

      ##
      # Datadog handler wrapper
      def datadog(name, &block)
        define_method(name) do |event:nil, context:nil|
          ::Datadog::Lambda.wrap(event, context) do
            Yake.wrap(event, context, &block)
          end
        end
      end
    end
  end
end

extend Yake::Datadog::DSL
