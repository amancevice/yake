RSpec.describe Yake::API::DSL do
  let(:runtime_class) { Class.new { extend Yake::DSL ; extend Yake::API::DSL } }
  let(:runtime)       { runtime_class.new }

  before { runtime_class.logging :off }

  context "#route" do
    let(:context) { OpenStruct.new(aws_request_id: "<awsRequestId>") }
    let(:event) do
      {
        "body"            => Base64.strict_encode64({fizz: "buzz"}.to_json),
        "isBase64Encoded" => true,
        "routeKey"        => "POST /fizz",
      }
    end
    let(:error) do
      {
        "body"            => Base64.strict_encode64({fizz: "buzz"}.to_json),
        "isBase64Encoded" => true,
        "routeKey"        => "POST /buzz",
      }
    end

    before { runtime_class.post("/fizz") { |event, context| [ event, context] } }

    it "should route the event" do
      expect(runtime_class.route event, context).to eq [ event, context ]
    end

    it "should raise UndeclaredRoute" do
      expect { runtime_class.route error, context }.to raise_error(Yake::Errors::UndeclaredRoute)
    end
  end

  context "#respond" do
    it "should respond with 200 OK" do
      expect(runtime_class.respond 200, "FIZZ").to eq(statusCode: 200, body: "FIZZ", headers: {"content-length" => "4"})
    end

    it "should respond with 201 NO CONTENT" do
      expect(runtime_class.respond 201).to eq(statusCode: 201, headers: {"content-length" => "0"})
    end

    it "should respond with 302 REDIRECT" do
      expect(runtime_class.respond 302, nil, location: "https://example.com/").to eq(
        statusCode: 302,
        headers: {"content-length" => "0", "location" => "https://example.com/"},
      )
    end
  end

  context "#header" do
    it "should add a header to the defaults" do
      runtime_class.header("x-rspec-header" => "fizz")
      expect(runtime_class.instance_variable_get(:@headers)["x-rspec-header"]).to eq "fizz"
    end
  end

  context "#delete" do
    it "should define a DELETE /* method" do
      runtime_class.delete("/path/to/resource")
      expect(runtime_class.respond_to? :"DELETE /path/to/resource").to be true
    end
  end

  context "#get" do
    it "should define a GET /* method" do
      runtime_class.get("/path/to/resource")
      expect(runtime_class.respond_to? :"GET /path/to/resource").to be true
    end
  end

  context "#head" do
    it "should define a HEAD /* method" do
      runtime_class.head("/path/to/resource")
      expect(runtime_class.respond_to? :"HEAD /path/to/resource").to be true
    end
  end

  context "#options" do
    it "should define a OPTIONS /* method" do
      runtime_class.options("/path/to/resource")
      expect(runtime_class.respond_to? :"OPTIONS /path/to/resource").to be true
    end
  end

  context "#patch" do
    it "should define a PATCH /* method" do
      runtime_class.patch("/path/to/resource")
      expect(runtime_class.respond_to? :"PATCH /path/to/resource").to be true
    end
  end

  context "#post" do
    it "should define a POST /* method" do
      runtime_class.post("/path/to/resource")
      expect(runtime_class.respond_to? :"POST /path/to/resource").to be true
    end
  end

  context "#put" do
    it "should define a PUT /* method" do
      runtime_class.put("/path/to/resource")
      expect(runtime_class.respond_to? :"PUT /path/to/resource").to be true
    end
  end
end
