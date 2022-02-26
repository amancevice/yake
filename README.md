# λake

![gem](https://img.shields.io/gem/v/yake?color=crimson&logo=rubygems&logoColor=eee&style=flat-square)
[![rspec](https://img.shields.io/github/workflow/status/amancevice/yake/RSpec?logo=github&style=flat-square)](https://github.com/amancevice/yake/actions)
[![coverage](https://img.shields.io/codeclimate/coverage/amancevice/yake?logo=code-climate&style=flat-square)](https://codeclimate.com/github/amancevice/yake/test_coverage)
[![maintainability](https://img.shields.io/codeclimate/maintainability/amancevice/yake?logo=code-climate&style=flat-square)](https://codeclimate.com/github/amancevice/yake/maintainability)

Write your AWS Lambda function handlers using a Rake-like declarative syntax:

```ruby
# ./lambda_function.rb
require 'yake'

handler :lambda_handler do |event|
  # Your code here
end

# Handler signature: `lambda_function.lambda_handler`
```

You can even declare Sinatra-like API Gateway routes for a main entrypoint:

```ruby
# ./lambda_function.rb
require 'yake/api'

header 'content-type' => 'application/json'

get '/fizz' do
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
gem 'yake'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install yake
```

## Why Is It Called "yake"?

"λ" + Rake, but "λ" is hard to type and I think "y" looks like a funny little upside-down-and-backwards Lambda symbol.

## Why Use It?

So why use `yake` for your Lambda functions?

#### Event Logging

By default, the `handler` function wraps its block in log lines formatted to match the style of Amazon's native Lambda logs sent to CloudWatch. Each invocation of the handler will log both the _input event_ and the _returned value_, prefixed with the ID of the request:

```
START RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf Version: $LATEST
INFO RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf EVENT { … }
…
INFO RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf RETURN { … }
END RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf
REPORT RequestId: 149c500f-028a-4b57-8977-0ef568cf8caf	Duration: 43.97 ms	Billed Duration: 44 ms	Memory Size: 128 MB	Max Memory Used: 77 MB
```

Logging the request ID in this way makes gathering logs lines for a particular execution in CloudWatch much easier.

You can customize or disable the logger:

```ruby
logging :off              # disables logging entirely
logging pretty: false     # Logs event/result in compact JSON
logging :on, MyLogger.new # Use a custom logger
```

Include `Yake::Logger` on a class to access this logger:

```ruby
class Fizz
  include Yake::Logger
end

Fizz.new.logger == Yake.logger
# => true
```

#### API Routes

A common use of Lambda functions is as a proxy for API Gateway. Oftentimes users will deploy a single Lambda function to handle all requests coming from API Gateway.

Requiring the `yake/api` module will add the API-specific DSL into your handler.

Define API routes using Sinatra-like syntax

```ruby
any '/…' do |event|
  # Handle 'ANY /…' route key events
end

delete '/…' do |event|
  # Handle 'DELETE /…' route key events
end

get '/…' do |event|
  # Handle 'GET /…' route key events
end

head '/…' do |event|
  # Handle 'HEAD /…' route key events
end

options '/…' do |event|
  # Handle 'OPTIONS /…' route key events
end

patch '/…' do |event|
  # Handle 'PATCH /…' route key events
end

post '/…' do |event|
  # Handle 'POST /…' route key events
end

put '/…' do |event|
  # Handle 'PUT /…' route key events
end
```

Helper methods are also made available to help produce a response for API Gateway:

Set a default header for ALL responses:

```ruby
header 'content-type' => 'application/json; charset=utf-8'
header 'x-custom-header' => 'fizz'
```

Produce an API Gateway-style response object:

```ruby
respond 200, { ok: true }.to_json, 'x-extra-header' => 'buzz'
# {
#   "statusCode" => 200,
#   "body" => '{"ok":true}',
#   "headers" => { "x-extra-header" => "buzz" }
# }
```

Route an event to one of the declared routes:

```ruby
handler :lambda_handler do |event|
  route event
rescue Yake::UndeclaredRoute => err
  respond 404, { message: err.message }.to_json
rescue => err
  respond 500, { message: err.message }.to_json
end
```

#### Zero Dependencies

Finally, `yake` does not depend on any other gems, using the Ruby stdlib only. This helps keep your Lambda packages slim & speedy.

## Support Helpers

As of `v0.5`, `yake` comes with a support module for common transformations.

`Hash` transformations:

```ruby
require 'yake/support'

{ fizz: 'buzz' }.encode64
# => "eyJmaXp6IjoiYnV6eiJ9\n"

{ fizz: 'buzz' }.strict_encode64
# => "eyJmaXp6IjoiYnV6eiJ9"

{ 'fizz' => { 'buzz' => %w[jazz fuzz] } }.symbolize_names
# => { :fizz => { :buzz => ["jazz", "fuzz"] } }

{ fizz: 'buzz' }.to_form
# => "fizz=buzz"
```

`Integer` transformations:

```ruby
7.days
# => 604800

7.hours
# => 25200

7.minutes
# => 420

1234567890.utc
# => 2009-02-13 23:31:30 UTC
```

`String` transformations:

```ruby
'snake_case_string'.camel_case
# => SnakeCaseString

"Zml6eg==\n".decode64
# => "fizz"

'fizz'.encode64
# => "Zml6eg==\n"

'CamelCaseString'.snake_case
# => 'camel_case_string'

'Zml6eg=='.strict_decode64
# => "fizz"

'fizz'.strict_encode64
# => "Zml6eg=="

'{"fizz":"buzz"}'.to_h_from_json
# => { "fizz" => "buzz" }

'fizz=buzz'.to_h_from_form
# => { "fizz" => "buzz" }
```

`Symbol` transformations

```ruby
:snake_case_symbol.camel_case
# => :SnakeCaseSymbol

:CamelCaseSymbol.snake_case
# => 'camel_case_symbol'
```

`UTC` Time helper

```ruby
UTC.at 1234567890
# => 2009-02-13 23:31:30 UTC

UTC.now
# => 2022-02-26 13:57:07.860539 UTC
```

## Datadog Integration

As of `~> 0.4`, `yake` comes with a helper for writing Lambdas that integrate with Datadog's `datadog-ruby` gem.

Creating a Lambda handler that wraps the Datadog tooling is easy:

```ruby
require 'aws-sdk-someservice'
require 'yake/datadog'

# Configure Datadog to use AWS tracing
Datadog::Lambda.configure_apm { |config| config.use :aws }

datadog :handler do |event|
  # …
end
```

## Deployment

After writing your Lambda handler code you can deploy it to AWS using any number of tools. I recommend the following tools:

- [Terraform](https://www.terraform.io) — my personal favorite Infrastructure-as-Code tool
- [AWS SAM](https://aws.amazon.com/serverless/sam/) — a great alternative with less configuration than Terraform
- [Serverless](https://www.serverless.com) — Supposedly the most popular option, though I have not used it

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amancevice/yake.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
