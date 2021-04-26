RSpec.describe Yake::Logger do
  let(:context) { OpenStruct.new(aws_request_id: "<awsRequestId>") }
  let(:stream) { StringIO.new }

  context "#new" do
    it "should use STDOUT by default" do
      expect(subject.instance_variable_get(:@logdev).dev).to eq $stdout
    end

    it "should use stream if supplied" do
      expect(Yake::Logger.new(stream).instance_variable_get(:@logdev).dev).to eq stream
    end
  end

  context "#wrap" do
    subject { Yake::Logger.new(stream) }

    it "should log the event and the result without context" do
      ret = subject.wrap({fizz: "buzz"}) { |x| x.transform_keys(&:upcase) }
      expect(ret).to eq FIZZ: "buzz"
      stream.seek 0
      expect(stream.read).to eq <<~EOS
        INFO - EVENT {"fizz":"buzz"}
        INFO - RETURN {"FIZZ":"buzz"}
      EOS
      expect(subject.progname).to eq "-"
    end

    it "should log the event and the result with context" do
      ret = subject.wrap({fizz: "buzz"}, context) { |x| x.transform_keys(&:upcase) }
      expect(ret).to eq FIZZ: "buzz"
      stream.seek 0
      expect(stream.read).to eq <<~EOS
        INFO RequestId: <awsRequestId> EVENT {"fizz":"buzz"}
        INFO RequestId: <awsRequestId> RETURN {"FIZZ":"buzz"}
      EOS
      expect(subject.progname).to eq "-"
    end
  end
end

RSpec.describe Yake::Loggable do
  context "#logger" do
    it "should get a new logger" do
      expect(Yake.logger).not_to be nil
    end
  end
end
