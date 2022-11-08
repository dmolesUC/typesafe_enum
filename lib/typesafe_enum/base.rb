# frozen_string_literal: true

require 'typesafe_enum/exceptions'
require 'typesafe_enum/class_methods'

# A Ruby implementation of Joshua Bloch's
# [typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums)
module TypesafeEnum

  # Base class for typesafe enum classes.
  class Base
    include Comparable

    class << self
      include ClassMethods
    end

    # The symbol key for the enum instance
    # @return [Symbol] the key
    attr_reader :key

    # The value encapsulated by the enum instance
    # @return [Object] the value
    attr_reader :value

    # The ordinal of the enum instance, in declaration order
    # @return [Integer] the ordinal
    attr_reader :ord

    # Compares two instances of the same enum class based on their declaration order
    # @param other [self] the enum instance to compare
    # @return [Integer, nil] -1 if this value precedes `other`; 0 if the two are
    #   the same enum instance; 1 if this value follows `other`; `nil` if `other`
    #   is not an instance of this enum class
    def <=>(other)
      # in the case where the enum being compared is actually the parent
      # class, only `==` will work correctly & we cannot use #is_a? or
      # #instance_of?
      ord <=> other.ord if self.class == other.class
    end

    # Generates a Fixnum hash value for this enum instance
    # @return [Fixnum] the hash value
    def hash
      @hash ||= begin
        result = 17
        result = 31 * result + self.class.hash
        result = 31 * result + ord
        result.is_a?(Integer) ? result : result.hash
      end
    end

    # Default implementation includes the enum class, `key`,
    # `ord` and `value`.
    # @return [String] a string representation of the enum instance
    def to_s
      "#{self.class}::#{key} [#{ord}] -> #{value.inspect}"
    end

    private

    IMPLICIT = Class.new.new
    private_constant :IMPLICIT

    # TODO: is documentation on this still accurate? does it still need to be private?
    def initialize(key, value = IMPLICIT, &block)
      raise TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)

      @key = key
      @value = value == IMPLICIT ? key.to_s.downcase : value
      @ord = self.class.size
      self.class.class_exec(self) do |instance|
        register(instance)
        instance.instance_eval(&block) if block_given?
      end
    end

    private_class_method :new

  end
end
