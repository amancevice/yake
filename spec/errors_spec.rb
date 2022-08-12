RSpec.describe Yake::Errors do
  context '::[]' do
    it 'should return NotFound' do
      expect(Yake::Errors[404]).to be Yake::Errors::NotFound
    end
  end
end
