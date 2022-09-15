# frozen_string_literal: true

# A Ruby implementation of Joshua Bloch's
# [typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums)
module TypesafeEnum
  # Base class for typesafe enum classes.
  class Base
    include Comparable

    class << self
      include Enumerable

      # Returns an array of the enum instances in declaration order
      # @return [Array<self>] All instances of this enum, in declaration order
      def to_a
        as_array.dup
      end

      # Returns the number of enum instances
      # @return [Integer] the number of instances
      def size
        as_array.size
      end

      # Iterates over the set of enum instances
      # @yield [self] Each instance of this enum, in declaration order
      # @return [Enumerator<self>] All instances of this enum, in declaration order
      def each(&block)
        to_a.each(&block)
      end

      # The set of all keys of all enum instances
      # @return [Enumerator<Symbol>] All keys of all enums, in declaration order
      def keys
        to_a.map(&:key)
      end

      # The set of all values of all enum instances
      # @return [Enumerator<Object>] All values of all enums, in declaration order
      def values
        to_a.map(&:value)
      end

      # Iterates over the set of keys of all instances (#keys)
      # @yield [Enumerator<Symbol>] Each key of each instance of this enum, in declaration order
      # @return [Enumerator<Symbol>]
      def each_key(&block)
        keys.each(&block)
      end

      # Iterates over the set of values of all instances (#values)
      # @yield [Enumerator<Object>] Each value of each instance of this enum, in declaration order
      # @return [Enumerator<Object>]
      def each_value(&block)
        values.each(&block)
      end

      # Looks up an enum instance based on its key
      # @param key [Symbol] the key to look up
      # @return [self, nil] the corresponding enum instance, or nil
      def find_by_key(key)
        by_key[key]
      end

      # Looks up an enum instance based on its value
      # @param value [Object] the value to look up
      # @return [self, nil] the corresponding enum instance, or nil
      def find_by_value(value)
        by_value[value]
      end

      # Looks up an enum instance based on the string representation of its value
      # @param value_str [String] the string form of the value
      # @return [self, nil] the corresponding enum instance, or nil
      def find_by_value_str(value_str)
        value_str = value_str.to_s
        by_value_str[value_str]
      end

      # Looks up an enum instance based on its ordinal
      # @param ord [Integer] the ordinal to look up
      # @return [self, nil] the corresponding enum instance, or nil
      def find_by_ord(ord)
        return nil if ord > size || ord.negative?

        as_array[ord]
      end

      private

      def by_key
        @by_key ||= {}
      end

      def by_value
        @by_value ||= {}
      end

      def by_value_str
        @by_value_str ||= {}
      end

      def as_array
        @as_array ||= []
      end

      def valid_key_and_value(instance)
        return unless (key = valid_key(instance))

        [key, valid_value(instance)]
      end

      def valid_key(instance)
        key = instance.key
        return key unless (found = find_by_key(key))

        value = instance.value
        raise NameError, "#{name}::#{key} already exists with value #{found.value.inspect}" unless value == found.value

        warn("ignoring redeclaration of #{name}::#{key} with value #{value.inspect} (source: #{caller(6..6).first})")
      end

      def valid_value(instance)
        value = instance.value
        return value unless (found = find_by_value(value))

        key = instance.key
        raise NameError, "A #{name} instance with value #{value.inspect} already exists: #{found.key}" unless key == found.key

        # valid_key() should already have warned us, and valid_key_and_value() should have exited early, but just in case
        # :nocov:
        warn("ignoring redeclaration of #{name}::#{key} with value #{value.inspect} (source: #{caller(6..6).first})")
        # :nocov:
      end

      def register(instance)
        key, value = valid_key_and_value(instance)
        return unless key

        const_set(key.to_s, instance)
        by_key[key] = instance
        by_value[value] = instance
        by_value_str[value.to_s] = instance
        as_array << instance
      end
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
