RSpec.describe Yake::API::DSL do
  let(:runtime_class) { Class.new { extend Yake::DSL ; extend Yake::API::DSL } }
  let(:runtime)       { runtime_class.new }

  before { runtime_class.logging :off }

  context '#route' do
    let(:context) { Struct.new(:aws_request_id).new('<awsRequestId>') }
    let(:event) do
      {
        'body'            => Base64.strict_encode64({fizz: 'buzz'}.to_json),
        'isBase64Encoded' => true,
        'routeKey'        => 'POST /fizz',
      }
    end
    let(:error) do
      {
        'body'            => Base64.strict_encode64({fizz: 'buzz'}.to_json),
        'isBase64Encoded' => true,
        'routeKey'        => 'POST /buzz',
      }
    end

    before { runtime_class.post('/fizz') { |event, context| [ event, context ] } }

    it 'should route the event' do
      expect(runtime_class.route event, context).to eq [ event, context ]
    end

    it 'should route the event and yield the block' do
      expect(runtime_class.route(event, context) { |res| event.keys }).to eq %w[body isBase64Encoded routeKey]
    end

    it 'should raise UndeclaredRoute' do
      expect { runtime_class.route error, context }.to raise_error(Yake::Errors::UndeclaredRoute)
    end
  end

  context '#respond' do
    it 'should respond with 200 OK' do
      expect(runtime_class.respond 200, 'FIZZ').to eq(statusCode: 200, body: 'FIZZ', headers: {'content-length' => '4'})
    end

    it 'should respond with 201 NO CONTENT' do
      expect(runtime_class.respond 201).to eq(statusCode: 201, headers: {'content-length' => '0'})
    end

    it 'should respond with 302 REDIRECT' do
      expect(runtime_class.respond 302, nil, location: 'https://example.com/').to eq(
        statusCode: 302,
        headers: {'content-length' => '0', 'location' => 'https://example.com/'},
      )
    end
  end

  context '#header' do
    it 'should add a header to the defaults' do
      runtime_class.header('x-rspec-header' => 'fizz')
      expect(runtime_class.instance_variable_get(:@headers)['x-rspec-header']).to eq 'fizz'
    end
  end

  context '#verbs' do
    %i[any delete get head options patch post put].each do |verb|
      it "should define a method for #{verb.upcase}" do
        runtime_class.send(verb, '/path/to/resource')
        expect(runtime_class.respond_to? :"#{verb.upcase} /path/to/resource").to be true
      end
    end
  end
end
