# frozen_string_literal: true

RSpec.describe Numeric do
  subject { 1_234_567_890 }

  context '#to_dynamodb' do
    it 'should convert the Hash to DynamoDB format' do
      expect(subject.to_dynamodb).to eq(N: '1234567890')
    end
  end
end
