# frozen_string_literal: true

require 'yake/datadog'

RSpec.describe Yake::Datadog::DSL do
  let(:event)         { { fizz: 'buzz' } }
  let(:runtime_class) { Class.new { extend Yake::Datadog::DSL } }
  let(:runtime)       { runtime_class.new }
  let(:context_class) { Struct.new(:aws_request_id, :function_name, :invoked_function_arn, :memory_limit_in_mb) }
  let(:context)       { context_class.new('<requestId>', '<functionName>', '<invokedFunctionArn>', 128) }

  before do
    require 'aws-sdk-core'
    Datadog::Lambda.configure_apm { |c| c.tracing.instrument :aws }
  end

  context '#datadog' do
    it 'should define a method called :fizz' do
      expect(runtime.respond_to?(:fizz)).to be false
      runtime_class.datadog(:fizz) { |event, context| [event, context] }
      expect(runtime.respond_to?(:fizz)).to be true
      expect(runtime.fizz(event: event, context: context)).to eq [event, context]
    end
  end
end

RSpec.describe Yake::Datadog::Formatter do
  context '#call' do
    let(:context)         { Struct.new(:aws_request_id).new('<awsRequestId>') }
    let(:formatter)       { Yake::Datadog::Formatter.new }
    let(:log_message)     { 'Hello, world!' }
    let(:log_correlation) { 'dd.service=rspec dd.trace_id=0 dd.span_id=0 ddsource=ruby' }
    let(:log_iso8601)     { '\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d.\d{3}Z' }
    let(:log_pattern)     { /\[INFO\] #{log_iso8601} - #{log_correlation} #{log_message}/ }
    let(:stream)          { StringIO.new }
    let(:utc)             { Time.at(1_234_567_890).utc }

    before { Yake.logger = Yake::Logger.new(stream, formatter: formatter, progname: '-') }

    it 'should format the log for Datadog' do
      Yake.logger.info(log_message)
      stream.seek 0
      expect(stream.read).to match log_pattern
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
