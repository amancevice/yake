RSpec.describe Yake::DSL do
  let(:runtime_class) { Class.new { extend Yake::DSL } }
  let(:runtime) { runtime_class.new }

  before { Yake.logger = Yake::Logger.new nil }

  context "#handler" do
    it "should define a method called :fizz" do
      expect(runtime.respond_to? :fizz).to be false
      runtime_class.handler(:fizz) { |event, context| [ event, context ] }
      expect(runtime.respond_to? :fizz).to be true
      expect(runtime.fizz event: 1, context: 2).to eq [ 1, 2 ]
    end
  end

  context "#logging" do
    it "should disable logging" do
      runtime_class.logging :off
      expect(Yake.logger).to be nil
    end

    it "should enable logging" do
      runtime_class.logging :on
      expect(Yake.logger).not_to be nil
    end

    it "should raise an error" do
      expect { runtime_class.logging :onoff }.to raise_error(Yake::Errors::UnknownLoggingSetting)
    end
  end
end
