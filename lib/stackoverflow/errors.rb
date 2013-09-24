module Stackoverflow
  module Errors
    class Error < ::StandardError
      attr_reader :id, :name

      def initialize(message, attrs = {})
        super(message)
        @id   = attrs.delete(:id)
        @name = attrs.delete(:name)
      end
    end

    class ThrottleViolation < Error
      attr_reader :backoff

      def initialize(message, attrs = {})
        super
        @backoff = attrs.delete(:backoff)
      end
    end
  end
end
