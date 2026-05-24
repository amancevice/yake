# frozen_string_literal: true

##
# Array helpers
class Array
  def pluck(key)  = map { |x| x[key] }
  def to_dynamodb = { L: map(&:to_dynamodb) }
end
