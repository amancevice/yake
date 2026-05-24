# frozen_string_literal: true

RSpec.describe Object do
  subject { 'Hello, World!' }

  context '#try' do
    it 'should try (and succeed) to execute the given method' do
      expect(subject.try(:encode, 'ascii')).to eq subject
    end

    it 'should try (and fail) to execute the given method' do
      expect(subject.try(:fizz)).to be nil
    end

    it 'should try (and fail) to execute the given method and yield' do
      expect(subject.try(:fizz) { |x| x.sub 'Hello', 'Goodbye' }).to eq 'Goodbye, World!'
    end
  end
end
