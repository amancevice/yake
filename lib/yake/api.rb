# frozen_string_literal: true

require "base64"
require "json"

require "yake"
require_relative "errors"

module Yake
  module API
    module DSL
      ##
      # Proxy handler for HTTP requests from Slack
      def route(event, context = nil, &block)
        # Extract route method
        method = event["routeKey"]
        raise Yake::Errors::UndeclaredRoute, method unless respond_to?(method)

        # Normalize headers
        event["headers"]&.transform_keys!(&:downcase)

        # Decode body if Base64-encoded
        if event["isBase64Encoded"]
          body = Base64.strict_decode64(event["body"])
          event.update("body" => body, "isBase64Encoded" => false)
        end

        # Execute request
        send(method, event, context).then { |res| block_given? ? yield(res) : res }
      end

      ##
      # Transform to API Gateway response
      def respond(status_code, body = nil, **headers)
        # Log response
        log = "RESPONSE [#{ status_code }] #{ body }"
        Yake.logger&.send(status_code.to_i >= 400 ? :error : :info, log)

        # Set headers
        content_length = (body&.length || 0).to_s
        to_s_downcase  = -> (key) { key.to_s.downcase }
        headers = {
          "content-length" => content_length,
          **(@headers || {}),
          **headers,
        }.transform_keys(&to_s_downcase).compact

        # Send response
        { statusCode: status_code, headers: headers, body: body }.compact
      end

      ##
      # Set default header
      def header(headers)
        (@headers ||= {}).update(headers)
      end

      ##
      # Define ANY route
      def any(path, &block)
        define_singleton_method("ANY #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define DELETE route
      def delete(path, &block)
        define_singleton_method("DELETE #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define GET route
      def get(path, &block)
        define_singleton_method("GET #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define HEAD route
      def head(path, &block)
        define_singleton_method("HEAD #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define OPTIONS route
      def options(path, &block)
        define_singleton_method("OPTIONS #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define PATCH route
      def patch(path, &block)
        define_singleton_method("PATCH #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define POST route
      def post(path, &block)
        define_singleton_method("POST #{ path }") { |*args| instance_exec(*args, &block) }
      end

      ##
      # Define PUT route
      def put(path, &block)
        define_singleton_method("PUT #{ path }") { |*args| instance_exec(*args, &block) }
      end
    end
  end
end

extend Yake::API::DSL
