# frozen_string_literal: true

##
# Hash helpers
class Hash
  def deep_keys               = map { |k, v| v.respond_to?(:deep_keys) ? [k] + v.deep_keys : k }.flatten
  def deep_sort               = sort.to_h { |k, v| [k, v.try(:deep_sort) { |x| x }] }
  def deep_transform_keys(&)  = deep_transform(:transform_keys, &)
  def deep_transform_keys!(&) = deep_transform(:transform_keys!, &)
  def encode64                = to_json.encode64
  def strict_encode64         = to_json.strict_encode64
  def stringify_names         = deep_transform_keys(&:to_s)
  def stringify_names!        = deep_transform_keys!(&:to_s)
  def symbolize_names         = deep_transform_keys(&:to_sym)
  def symbolize_names!        = deep_transform_keys!(&:to_sym)
  def to_form                 = URI.encode_www_form(self)
  def to_json_sorted          = deep_sort.to_json
  def to_struct               = Struct.new(*keys.map(&:to_sym)).new(*values)

  ##
  # Adapted from ActiveSupport Hash#deep_merge
  # https://github.com/rails/rails/blob/f95c0b7e96eb36bc3efc0c5beffbb9e84ea664e4/activesupport/lib/active_support/core_ext/hash/deep_merge.rb
  def deep_merge(other, &block) # rubocop: disable Metrics/MethodLength
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

  def to_deep_struct # rubocop: disable Metrics/MethodLength
    to_struct.tap do |struct|
      struct.to_h.each do |key, val|
        struct[key] =
          if val.is_a?(Array)
            val.map { |i| i.respond_to?(:to_deep_struct) ? i.to_deep_struct : i }
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

  def to_h_from_dynamodb # rubocop: disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    decode = lambda do |i|
      type, val = i.first
      case type.to_sym
      when :S then val
      when :N then val =~ /^[0-9]+$/ ? val.to_i : val.to_f
      when :L then val.map(&decode)
      when :M then val.transform_values(&decode)
      end
    end
    map do |key, val|
      { key => decode.call(val) }
    end.reduce(&:merge)
  end

  private

  def deep_transform(method, &block)
    f = ->(x) { x.respond_to?(:"deep_#{method}") ? x.send(:"deep_#{method}", &block) : x }
    if block_given?
      send(method, &block).to_h do |key, val|
        [key, val.is_a?(Array) ? val.map(&f) : val.then(&f)]
      end
    else
      self
    end
  end
end
