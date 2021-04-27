# λake

Write your AWS Lambda function handlers using a Rake-like declarative syntax:

```ruby
# ./lambda_function.rb
require "yake"

handler :lambda_handler do |event|
  # Your code here
end

# Handler signature: `lambda_function.lambda_handler`
```

You can even declare Sinatra-like API Gateway routes for a main entrypoint:

```ruby
# ./lambda_function.rb
require "yake/api"

header "content-type" => "application/json"

get "/fizz" do |handler|
  respond 200, { ok: true }.to_json
end

handler :lambda_handler do |event|
  route event
rescue => err
  respond 500, { message: err.message }.to_json
end

# Handler signature: `lambda_function.lambda_handler`
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "yake"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install yake
```

## Why Use It?

So why use `yake` for your Lambda functions?

#### Zero Dependencies

`yake` does not depend on any other gems, using the Ruby stdlib only. This helps keep your Lambda packages slim & speedy.

#### Event Logging

By default, the `handler` function wraps its block in log lines formatted to match the style of Amazon's native Lambda logs sent to CloudWatch. Each invocation of the handler logs the input event and the returned value prefixed with the ID of the request.

Example log lines:

```
START RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf Version: $LATEST
INFO RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf EVENT { … }
…
INFO RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf RETURN { … }
END RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf
REPORT RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf	Duration: 43.97 ms	Billed Duration: 44 ms	Memory Size: 128 MB	Max Memory Used: 77 MB
```

This makes gathering logs lines for a particular execution in CloudWatch much easier.

This feature can be disabled by adding a declaration in your handler:

```ruby
logging :off
```

#### API Routes

A common use of Lambda functions is as a proxy for API Gateway. Oftentimes users will deploy a single Lambda function to handle all requests coming from API Gateway.

Requiring the `yake/api` module will add the API-specific DSL into your handler.

Define API routes using Sinatra-like syntax

```ruby
# Declare 'DELETE /…' route key
delete "/…" do |event|
  # …
end

# Declare 'GET /…' route key
get "/…" do |event|
  # …
end

# Declare 'HEAD /…' route key
head "/…" do |event|
  # …
end

# Declare 'OPTIONS /…' route key
options "/…" do |event|
  # …
end

# Declare 'PATCH /…' route key
patch "/…" do |event|
  # …
end

# Declare 'POST /…' route key
post "/…" do |event|
  # …
end

# Declare 'PUT /…' route key
put "/…" do |event|
  # …
end

```

Helper methods are also made available to help produce a response for API Gateway:

Set a default header for ALL responses:

```ruby
header "content-type" => "application/json; charset=utf-8"
```

Produce an API Gateway-style response object:

```ruby
respond 200, { ok: true }.to_json, "x-extra-header" => "fizz"
# {
#   "statusCode" => 200,
#   "body" => '{"ok":true}',
#   "headers" => { "x-extra-header" => "fizz" }
# }
```

Route an event to one of the declared routes:

```ruby
begin
  route event
rescue Yake::UndeclaredRoute => err
  respond 404, { message: err.message }.to_json
rescue => err
  respond 500 { message: err.message }.to_json
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amancevice/yake.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

```

```
