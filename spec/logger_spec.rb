RSpec.describe Yake::Logger do
  context "::new" do
    let(:stream) { StringIO.new }

    it "should use STDOUT by default" do
      expect(Yake::Logger.new.instance_variable_get(:@logdev).dev).to eq $stdout
    end

    it "should use stream if supplied" do
      expect(Yake::Logger.new(stream).instance_variable_get(:@logdev).dev).to eq stream
    end
  end

  context "::included" do
    subject { Class.new { include Yake::Logger }.new }

    it "should use Yake::logger" do
      expect(subject.logger).to eq Yake.logger
    end
  end
end

RSpec.describe Yake do
  context "::wrap" do
    let(:context) { OpenStruct.new(aws_request_id: "<awsRequestId>") }
    let(:stream)  { StringIO.new }

    before { Yake.logger = Yake::Logger.new(stream, progname: "-") }

    it "should log the event and the result without context" do
      ret = subject.wrap({fizz: "buzz"}) { |x| x.transform_keys(&:upcase) }
      expect(ret).to eq FIZZ: "buzz"
      stream.seek 0
      expect(stream.read).to eq <<~EOS
        INFO - EVENT {"fizz":"buzz"}
        INFO - RETURN {"FIZZ":"buzz"}
      EOS
      expect(subject.logger.progname).to eq "-"
    end

    it "should log the event and the result with context" do
      ret = subject.wrap({fizz: "buzz"}, context) { |x| x.transform_keys(&:upcase) }
      expect(ret).to eq FIZZ: "buzz"
      stream.seek 0
      expect(stream.read).to eq <<~EOS
        INFO RequestId: <awsRequestId> EVENT {"fizz":"buzz"}
        INFO RequestId: <awsRequestId> RETURN {"FIZZ":"buzz"}
      EOS
      expect(subject.logger.progname).to eq "-"
    end
  end
end
