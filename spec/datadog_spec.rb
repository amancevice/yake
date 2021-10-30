RSpec.describe Yake::Datadog::DSL do
  let(:event)         { { fizz: 'buzz' } }
  let(:context)       { OpenStruct.new aws_request_id: '<requestId>', invoked_function_arn: '' }
  let(:runtime_class) { Class.new { extend Yake::Datadog::DSL } }
  let(:runtime)       { runtime_class.new }

  before do
    runtime_class.logging :off
    require 'aws-sdk-core'
    Datadog::Lambda.configure_apm { |config| config.use :aws }
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

RSpec.describe Yake::Datadog::MockContext do
  context '#invoked_function_arn' do
    it 'should return a mock function ARN' do
      expect(subject.invoked_function_arn).to eq 'arn:aws:lambda:us-east-1:123456789012:function-name'
    end
  end
end
