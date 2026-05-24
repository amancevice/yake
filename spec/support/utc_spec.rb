# frozen_string_literal: true

RSpec.describe UTC do
  context '::at' do
    it 'should interpret an Integer as a Time in UTC' do
      expect(UTC.at(1_234_567_890)).to eq Time.at(1_234_567_890).utc
    end
  end

  context '::now' do
    it 'should consruct the current time in UTC' do
      expect(UTC.now.iso8601).to eq Time.now.utc.iso8601
    end
  end
end
