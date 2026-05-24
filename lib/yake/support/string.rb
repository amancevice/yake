# frozen_string_literal: true

##
# String helpers
class String
  def /(other) = File.join(self, other.to_s)
  def camel_case          = split(/[_ ]/).map(&:capitalize).join
  def decode64            = unpack1('m')
  def encode64            = [self].pack('m')
  def md5sum              = Digest::MD5.hexdigest(self)
  def sha1sum             = Digest::SHA1.hexdigest(self)
  def snake_case          = gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/ /, '_').downcase
  def strict_decode64     = unpack1('m0')
  def strict_encode64     = [self].pack('m0')
  def to_dynamodb         = { S: self }
  def to_h_from_json(...) = JSON.parse(self, ...)
  def to_h_from_form      = URI.decode_www_form(self).to_h
  def utc                 = UTC.parse(self)
end
