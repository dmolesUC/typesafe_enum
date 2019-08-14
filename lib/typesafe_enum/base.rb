# frozen_string_literal: true

# A Ruby implementation of Joshua Bloch's
# [typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums)
module TypesafeEnum
  # Base class for typesafe enum classes.
  class Base
    include Comparable

    class << self

      # Returns an array of the enum instances in declaration order
      # @return [Array<self>] All instances of this enum, in declaration order
      def to_a
        as_array.dup
      end

      # Returns the number of enum instances
      # @return [Integer] the number of instances
      def size
        as_array ? as_array.length : 0
      end

      # Iterates over the set of enum instances
      # @yield [self] Each instance of this enum, in declaration order
      # @return [Array<self>] All instances of this enum, in declaration order
      def each(&block)
        to_a.each(&block)
      end

      # Iterates over the set of enum instances
      # @yield [self, Integer] Each instance of this enum, in declaration order,
      #   with its ordinal index
      # @return [Array<self>] All instances of this enum, in declaration order
      def each_with_index(&block)
        to_a.each_with_index(&block)
      end

      # Iterates over the set of enum instances
      # @yield [self] Each instance of this enum, in declaration order
      # @return [Array] An array containing the result of applying `&block`
      #   to each instance of this enum, in instance declaration order
      def map(&block)
        to_a.map(&block)
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
        key = instance.key
        value = instance.value
        if (found = find_by_key(key))
          raise NameError, "#{name}::#{key} already exists" unless value == found.value

          warn("ignoring redeclaration of #{name}::#{key} with value #{value} (source: #{caller(5..5).first})")
          nil
        else
          raise NameError, "A #{name} instance with value '#{value}' already exists" if find_by_value(value)

          [key, value]
        end
      end

      def register(instance)
        key, value = valid_key_and_value(instance)
        return unless key && value

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
      "#{self.class}::#{key} [#{ord}] -> #{value}"
    end

    private

    def initialize(key, value = nil, &block)
      raise TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)

      @key = key
      @value = value || key.to_s.downcase
      @ord = self.class.size
      self.class.class_exec(self) do |instance|
        register(instance)
        instance.instance_eval(&block) if block_given?
      end
    end

    private_class_method :new

  end
end
