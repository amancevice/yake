# frozen_string_literal: true

module Yake
  module Errors
    class Error < StandardError; end

    class UndeclaredRoute < Error
      def initialize(method = nil)
        super("No route declared for '#{ method }'")
      end
    end

    class UnknownLoggingSetting < Error
      def initialize(method = nil)
        super("Unknown logging setting '#{ method }'. Use :on or :off")
      end
    end

    # HTTP Errors

    class BadRequest < Error; end                    # HTTP 400
    class Unauthorized < Error; end                  # HTTP 401
    class PaymentRequired < Error; end               # HTTP 402
    class Forbidden < Error; end                     # HTTP 403
    class NotFound < Error; end                      # HTTP 404
    class MethodNotAllowed < Error; end              # HTTP 405
    class NotAcceptable < Error; end                 # HTTP 406
    class ProxyAuthenticationRequired < Error; end   # HTTP 407
    class RequestTimeout < Error; end                # HTTP 408
    class Conflict < Error; end                      # HTTP 409
    class Gone < Error; end                          # HTTP 410
    class LengthRequired < Error; end                # HTTP 410
    class PreconditionFailed < Error; end            # HTTP 412
    class PayloadTooLarge < Error; end               # HTTP 413
    class UriTooLong < Error; end                    # HTTP 414
    class UnsupportedMediaType < Error; end          # HTTP 415
    class RangeNotSatisfiable < Error; end           # HTTP 416
    class ExpectationFailed < Error; end             # HTTP 417
    class ImATeapot < Error; end                     # HTTP 418
    class EnhanceYourCalm < Error; end               # HTTP 420
    class MisdirectedRequest < Error; end            # HTTP 421
    class UnprocessableEntity < Error; end           # HTTP 422
    class Locked < Error; end                        # HTTP 423
    class FailedDependency < Error; end              # HTTP 424
    class TooEarly < Error; end                      # HTTP 425
    class UpgradeRequired < Error; end               # HTTP 426
    class PreconditionRequired < Error; end          # HTTP 428
    class TooManyRequests < Error; end               # HTTP 429
    class RequestHeaderFieldsTooLarge < Error; end   # HTTP 431
    class UnavailableForLegalReasons < Error; end    # HTTP 451
    class InternalServerError < Error; end           # HTTP 500
    class NotImplemented < Error; end                # HTTP 501
    class BadGateway < Error; end                    # HTTP 502
    class ServiceUnavailable < Error; end            # HTTP 503
    class GatewayTimeout < Error; end                # HTTP 504
    class HttpVersionNotSupported < Error; end       # HTTP 505
    class VariantAlsoNegotiates < Error; end         # HTTP 506
    class InsufficientStorage < Error; end           # HTTP 507
    class LoopDetected < Error; end                  # HTTP 508
    class NotExtended < Error; end                   # HTTP 510
    class NetworkAuthenticationRequired < Error; end # HTTP 507
  end
end
