# --- Define Lambda handler(s)

require "yake/api"

@fizzes = []
@buzzes = []

header "content-type" => "application/json; charset=utf-8"

get "/fizz" do |event|
  respond 200, { fizzes: @fizzes }.to_json
end

get "/buzz" do |event|
  respond 200, { fizzes: @buzzes }.to_json
end

post "/fizz" do |event|
  @fizzes << event["body"]
  respond 201
end

post "/buzz" do |event|
  @buzzes << event["body"]
  respond 201
end

handler :proxy do |event|
  route event
rescue Yake::Errors::UndeclaredRoute => err
  respond 404, { message: err.message }.to_json
rescue => err
  respond 500, { message: err.message }.to_json
end

# --- Example invocation(s)

require "securerandom"
context = -> { OpenStruct.new aws_request_id: SecureRandom.uuid }
proxy event: { "routeKey" => "POST /fizz", "body" => "FIZZ 1" }, context: context.call
proxy event: { "routeKey" => "POST /fizz", "body" => "FIZZ 2" }, context: context.call
proxy event: { "routeKey" => "POST /buzz", "body" => "BUZZ 1" }, context: context.call
proxy event: { "routeKey" => "POST /buzz", "body" => "BUZZ 2" }, context: context.call
proxy event: { "routeKey" => "GET /fizz" }, context: context.call
proxy event: { "routeKey" => "GET /buzz" }, context: context.call
