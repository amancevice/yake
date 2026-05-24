# frozen_string_literal: true

##
# Object helpers
class Object
  def try(method, *, **, &)
    public_send(method, *, **)
  rescue NoMethodError
    block_given? ? yield(self) : nil
  end
end
