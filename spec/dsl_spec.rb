RSpec.describe Yake::DSL do
  let(:event)         { { fizz: 'buzz' } }
  let(:context)       { OpenStruct.new aws_request_id: '<requestId>' }
  let(:runtime_class) { Class.new { extend Yake::DSL } }
  let(:runtime)       { runtime_class.new }

  before { runtime_class.logging :off }

  context '#handler' do
    it 'should define a method called :fizz' do
      expect(runtime.respond_to? :fizz).to be false
      runtime_class.handler(:fizz) { |event, context| [ event, context ] }
      expect(runtime.respond_to? :fizz).to be true
      expect(runtime.fizz event: event, context: context).to eq [ event, context ]
    end
  end

  context '#logger' do
    it 'should return the logger' do
      expect(runtime_class.logger).to eq Yake.logger
    end
  end

  context '#logging' do
    it 'should disable logging' do
      runtime_class.logging :off
      expect(Yake.logger.instance_variable_get :@logdev).to be nil
    end

    it 'should enable logging' do
      runtime_class.logging :on
      expect(Yake.logger.instance_variable_get :@logdev).not_to be nil
    end

    it 'should raise an error' do
      expect { runtime_class.logging :onoff }.to raise_error(Yake::Errors::UnknownLoggingSetting)
    end
  end
end
