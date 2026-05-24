# frozen_string_literal: true

##
# Numeric helpers
class Numeric
  def to_dynamodb = { N: to_s }
end
