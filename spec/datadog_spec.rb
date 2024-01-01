RSpec.describe Yake::Datadog::DSL do
  let(:event)         { { fizz: 'buzz' } }
  let(:context)       { OpenStruct.new aws_request_id: '<requestId>', invoked_function_arn: '' }
  let(:runtime_class) { Class.new { extend Yake::Datadog::DSL } }
  let(:runtime)       { runtime_class.new }

  before do
    runtime_class.logging :off
    require 'aws-sdk-core'
    Datadog::Lambda.configure_apm { |c| c.tracing.instrument :aws }
  end

  context '#datadog' do
    it 'should define a method called :fizz' do
      expect(runtime.respond_to? :fizz).to be false
      runtime_class.datadog(:fizz) { |event, context| [ event, context ] }
      expect(runtime.respond_to? :fizz).to be true
      expect(runtime.fizz event: event, context: context).to eq [ event, context ]
    end
  end
end

RSpec.describe Yake::Datadog::Formatter do
  context '#call' do
    let(:context)   { OpenStruct.new(aws_request_id: '<awsRequestId>') }
    let(:formatter) { Yake::Datadog::Formatter.new }
    let(:stream)    { StringIO.new }
    let(:utc)       { Time.at(1234567890).utc }

    before { Yake.logger = Yake::Logger.new(stream, formatter: formatter, progname: '-') }

    it 'should format the log for Datadog' do
      allow_any_instance_of(Time).to receive(:utc).and_return utc
      Yake.logger.info('Hello, world!')
      stream.seek 0
      expect(stream.read).to eq <<~EOS
        [INFO] 2009-02-13T23:31:30.000Z - dd.service=rspec dd.trace_id=0 dd.span_id=0 ddsource=ruby Hello, world!
      EOS
    end
  end
end

RSpec.describe Yake::Datadog::MockContext do
  context '#invoked_function_arn' do
    it 'should return a mock function ARN' do
      expect(subject.invoked_function_arn).to eq 'arn:aws:lambda:us-east-1:123456789012:function-name'
    end
  end
end
