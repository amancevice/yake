# --- Define Lambda handler(s)

require 'json'

require 'yake'

handler :handler do |event, context|
  { received: event, aws_request_id: context&.aws_request_id }
end

# --- Example invocation(s)

handler event: { 'key' => 'value' },
        context: OpenStruct.new(aws_request_id: SecureRandom.uuid)
