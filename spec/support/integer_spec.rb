# frozen_string_literal: true

RSpec.describe Integer do
  subject { 1_234_567_890 }

  context '#weeks' do
    it 'should convert the Integer from weeks to seconds' do
      expect(subject.weeks).to eq 746_666_659_872_000
    end
  end

  context '#days' do
    it 'should convert the Integer from days to seconds' do
      expect(subject.days).to eq 106_666_665_696_000
    end
  end

  context '#hours' do
    it 'should convert the Integer from hours to seconds' do
      expect(subject.hours).to eq 4_444_444_404_000
    end
  end

  context '#minutes' do
    it 'should convert the Integer from minutes to seconds' do
      expect(subject.minutes).to eq 74_074_073_400
    end
  end

  context '#seconds' do
    it 'should convert the Integer from seconds to seconds' do
      expect(subject.seconds).to eq 1_234_567_890
    end
  end

  context '#utc' do
    it 'should convert the Integer to a Time object in the UTC timezone' do
      expect(subject.utc).to eq Time.at(subject).utc
    end
  end
end
