# frozen_string_literal: true

require 'json'

require 'yake'
require_relative 'errors'

module Yake
  module API
    ##
    # Yake API DSL
    module DSL
      ##
      # Proxy handler for HTTP requests from API Gateway
      def route(event, context = nil)
        # Extract route method
        method = event['routeKey']
        raise Yake::Errors::UndeclaredRoute, method unless respond_to?(method)

        # Normalize headers
        event['headers']&.transform_keys!(&:downcase)

        # Decode body if Base64-encoded
        if event['isBase64Encoded']
          body = event['body'].unpack1('m0')
          event.update('body' => body, 'isBase64Encoded' => false)
        end

        # Execute request
        res = send(method, event, context)
        block_given? ? yield(res) : res
      end

      ##
      # Transform to API Gateway response
      def respond(status_code, body = nil, **headers)
        # Log response
        log = "RESPONSE [#{status_code}] #{body}"
        Yake.logger&.send(status_code.to_i >= 400 ? :error : :info, log)

        # Set headers
        content_length = (body&.bytesize || 0).to_s
        to_s_downcase  = ->(key) { key.to_s.downcase }
        headers = {
          'content-length' => content_length,
          **(@headers || {}),
          **headers
        }.transform_keys(&to_s_downcase).compact

        # Send response
        { statusCode: status_code, headers:, body: }.compact
      end

      ##
      # Set default header
      def header(headers)
        (@headers ||= {}).update(headers)
      end

      %w[ANY DELETE GET HEAD OPTIONS PATCH POST PUT].each do |verb|
        define_method(verb.downcase) do |path, &block|
          define_singleton_method("#{verb} #{path}") { |*args| instance_exec(*args, &block) }
        end
      end
    end
  end
end

extend Yake::API::DSL # rubocop: disable Style/MixinUsage
