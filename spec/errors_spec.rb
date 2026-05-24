# frozen_string_literal: true

RSpec.describe Yake::Errors do
  context '::[]' do
    it 'should return NotFound' do
      expect(Yake::Errors[404]).to be Yake::Errors::NotFound
    end

    it 'should raise CodeNotFound' do
      expect { Yake::Errors[999] }.to raise_error Yake::Errors::CodeNotFound
    end
  end
end
