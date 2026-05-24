# frozen_string_literal: true

##
# UTC time
class UTC < Time
  def initialize(...) = super.utc
  def self.at(...)    = super.utc
  def self.now        = super.utc
end
