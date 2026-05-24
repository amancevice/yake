# frozen_string_literal: true

##
# Integer helpers
class Integer
  def weeks   = days * 7
  def days    = hours * 24
  def hours   = minutes * 60
  def minutes = seconds * 60
  def seconds = self
  def utc     = UTC.at(self)

  alias second seconds
  alias minute minutes
  alias hour hours
  alias day days
  alias week weeks
end
