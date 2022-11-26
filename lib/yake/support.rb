# frozen_string_literal: true

require 'base64'
require 'digest'
require 'json'
require 'time'

class Hash
  def deep_keys() map { |k,v| v.respond_to?(:deep_keys) ? [k] + v.deep_keys : k }.flatten end
  def deep_sort() sort.map { |k,v| [ k, v.try(:deep_sort) { |x| x } ] }.to_h end
  def encode64() to_json.encode64 end
  def except(*keys) reject { |key,_| keys.include? key } end
  def strict_encode64() to_json.strict_encode64 end
  def stringify_names() deep_transform_keys(&:to_s) end
  def stringify_names!() deep_transform_keys!(&:to_s) end
  def symbolize_names() deep_transform_keys(&:to_sym) end
  def symbolize_names!() deep_transform_keys!(&:to_sym) end
  def to_form() URI.encode_www_form(self) end
  def to_json_sorted() deep_sort.to_json end
  def to_struct() OpenStruct.new(self) end

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

  def deep_transform_keys(&block)
    deep_transform(:transform_keys, &block)
  end

  def deep_transform_keys!(&block)
    deep_transform(:transform_keys!, &block)
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

  private def deep_transform(method, &block)
    f = -> (x) { x.respond_to?(:"deep_#{method}") ? x.send(:"deep_#{method}", &block) : x }
    block_given? ? send(method, &block).map do |key, val|
      [key, val.is_a?(Array) ? val.map(&f) : val.then(&f)]
    end.to_h : self
  end
end

class Integer
  def weeks() days * 7 end
  def days() hours * 24 end
  def hours() minutes * 60 end
  def minutes() seconds * 60 end
  def seconds() self end
  def utc() UTC.at(self) end

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
  def /(path) File.join(self, path.to_s) end
  def camel_case() split(/_/).map(&:capitalize).join end
  def decode64() Base64.decode64(self) end
  def encode64() Base64.encode64(self) end
  def md5sum() Digest::MD5.hexdigest(self) end
  def sha1sum() Digest::SHA1.hexdigest(self) end
  def snake_case() gsub(/([a-z])([A-Z])/, '\1_\2').downcase end
  def strict_decode64() Base64.strict_decode64(self) end
  def strict_encode64() Base64.strict_encode64(self) end
  def to_h_from_json(**params) JSON.parse(self, **params) end
  def to_h_from_form() URI.decode_www_form(self).to_h end
  def utc() UTC.parse(self) end
end

class Symbol
  def camel_case() to_s.camel_case.to_sym end
  def snake_case() to_s.snake_case.to_sym end
end

class UTC < Time
  def initialize(...) super.utc end
  def self.at(...) super.utc end
  def self.now() super.utc end
end
