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


  def deep_transform_keys(&block)
    block_given? ? transform_keys(&block).map do |key, val|
      val = val.deep_transform_keys(&block) if val.respond_to?(:deep_transform_keys)
      [key, val]
    end.to_h : self
  end

  def deep_transform_keys!(&block)
    block_given? ? transform_keys!(&block).map do |key, val|
      val = val.deep_transform_keys!(&block) if val.respond_to?(:deep_transform_keys!)
      [key, val]
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
