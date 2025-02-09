# frozen_string_literal: true

require 'digest'
require 'json'
require 'time'
require 'uri'

class Array
  def pluck(key)  = map { |x| x[key] }
  def to_dynamodb = { L: map(&:to_dynamodb) }
end

class Hash
  def deep_keys                     = map { |k,v| v.respond_to?(:deep_keys) ? [k] + v.deep_keys : k }.flatten
  def deep_sort                     = sort.map { |k,v| [ k, v.try(:deep_sort) { |x| x } ] }.to_h
  def deep_transform_keys(&block)   = deep_transform(:transform_keys, &block)
  def deep_transform_keys!(&block)  = deep_transform(:transform_keys!, &block)
  def encode64                      = to_json.encode64
  def except(*keys)                 = reject { |key,_| keys.include? key }
  def strict_encode64               = to_json.strict_encode64
  def stringify_names               = deep_transform_keys(&:to_s)
  def stringify_names!              = deep_transform_keys!(&:to_s)
  def symbolize_names               = deep_transform_keys(&:to_sym)
  def symbolize_names!              = deep_transform_keys!(&:to_sym)
  def to_form                       = URI.encode_www_form(self)
  def to_json_sorted                = deep_sort.to_json
  def to_struct                     = Struct.new(*keys.map(&:to_sym)).new(*values)

  ##
  # Adapted from ActiveSupport Hash#deep_merge
  # https://github.com/rails/rails/blob/f95c0b7e96eb36bc3efc0c5beffbb9e84ea664e4/activesupport/lib/active_support/core_ext/hash/deep_merge.rb
  def deep_merge(other, &block)
    merge(other) do |key, a, b|
      if a.is_a?(Hash) && b.is_a?(Hash)
        a.deep_merge(b, &block)
      elsif a.is_a?(Array) && b.is_a?(Array)
        a + b
      elsif block_given?
        yield key, a, b
      else
        b
      end
    end
  end

  def to_deep_struct
    to_struct.tap do |struct|
      struct.to_h.each do |key, val|
        struct[key] = if val.is_a?(Array)
          val.map do |item|
            item.respond_to?(:to_deep_struct) ? item.to_deep_struct : item
          end
        elsif val.is_a?(Hash)
          val.to_deep_struct
        else
          val
        end
      end
    end
  end

  def to_dynamodb
    map do |key, val|
      { key => val.is_a?(Hash) ? { M: val.to_dynamodb } : val.to_dynamodb }
    end.reduce(&:merge)
  end

  def to_h_from_dynamodb
    decode = -> (i) do
      type, val = i.first
      case type.to_sym
      when :S then val
      when :N then val =~ /^[0-9]+$/ ? val.to_i : val.to_f
      when :L then val.map(&decode)
      when :M then val.transform_values(&decode)
      end
    end
    map do |key, val|
      { key => decode === val }
    end.reduce(&:merge)
  end

  private

  def deep_transform(method, &block)
    f = -> (x) { x.respond_to?(:"deep_#{method}") ? x.send(:"deep_#{method}", &block) : x }
    block_given? ? send(method, &block).map do |key, val|
      [key, val.is_a?(Array) ? val.map(&f) : val.then(&f)]
    end.to_h : self
  end
end

class Numeric
  def to_dynamodb = { N: to_s }
end

class Integer
  def weeks   = days * 7
  def days    = hours * 24
  def hours   = minutes * 60
  def minutes = seconds * 60
  def seconds = self
  def utc     = UTC.at(self)

  alias :second :seconds
  alias :minute :minutes
  alias :hour :hours
  alias :day :days
  alias :week :weeks
end

class Object
  def try(method, *args, **kwargs, &block)
    send(method, *args, **kwargs)
  rescue
    block_given? ? yield(self) : nil
  end
end

class String
  def /(path)             = File.join(self, path.to_s)
  def camel_case          = split(/[_ ]/).map(&:capitalize).join
  def decode64            = self.unpack1('m')
  def encode64            = [self].pack('m')
  def md5sum              = Digest::MD5.hexdigest(self)
  def sha1sum             = Digest::SHA1.hexdigest(self)
  def snake_case          = gsub(/([a-z])([A-Z])/, '\1_\2').gsub(/ /, '_').downcase
  def strict_decode64     = self.unpack1('m0')
  def strict_encode64     = [self].pack('m0')
  def to_dynamodb         = { S: self }
  def to_h_from_json(...) = JSON.parse(self, ...)
  def to_h_from_form      = URI.decode_www_form(self).to_h
  def utc                 = UTC.parse(self)
end

class Symbol
  def camel_case  = to_s.camel_case.to_sym
  def snake_case  = to_s.snake_case.to_sym
  def to_dynamodb = { S: to_s }
end

class UTC < Time
  def initialize(...) = super.utc
  def self.at(...)    = super.utc
  def self.now        = super.utc
end
