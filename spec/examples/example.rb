require "yake/api"

header "content-type" => "application/json; charset=utf-8"

get "/" do |event|
  respond(201)
end

get "/fizz" do |event|
  respond(201)
end

handler :proxy do |event|
  route event
rescue Yake::Error => err
  respond 500, { message: err.message }.to_json
end

handler :fizz do |event|
  true
end
