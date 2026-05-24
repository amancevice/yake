# frozen_string_literal: true

RSpec.describe Symbol do
  context '#camel_case' do
    it 'should convert a snake_case String to CamelCase' do
      expect(:snake_case_symbol.camel_case).to eq :SnakeCaseSymbol
    end
  end

  context '#snake_case' do
    it 'should convert the String from CamelCase to snake_case' do
      expect(:SnakeCaseSymbol.snake_case).to eq :snake_case_symbol
    end
  end
end
