# frozen_string_literal: true

##
# Symbol helpers
class Symbol
  def camel_case  = to_s.camel_case.to_sym
  def snake_case  = to_s.snake_case.to_sym
  def to_dynamodb = { S: to_s }
end
