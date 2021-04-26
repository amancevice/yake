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
end
