# A Ruby implementation of Joshua Bloch's
# [typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums)
module TypesafeEnum
  # Base class for typesafe enum classes.
  class Base
    include Comparable

    class << self

      # Returns an array of the enum instances in declaration order
      def to_a
        as_array.dup
      end

      # Returns the number of enum instances
      def size
        as_array ? as_array.length : 0
      end

      # Iterates over the set of enum instances
      def each(&block)
        to_a.each(&block)
      end

      # Iterates over the set of enum instances
      def each_with_index(&block)
        to_a.each_with_index(&block)
      end

      # Iterates over the set of enum instances
      def map(&block)
        to_a.map(&block)
      end

      # Looks up an enum instance based on its key
      def find_by_key(key)
        by_key[key]
      end

      # Looks up an enum instance based on its value
      def find_by_value(value)
        by_value[value]
      end

      # Looks up an enum instance based on the string representation of its value
      def find_by_value_str(value_str)
        value_str = value_str.to_s
        by_value.each do |value, instance|
          return instance if value_str == value.to_s
        end
        nil
      end

      # Looks up an enum instance based on its ordinal
      def find_by_ord(ord)
        return nil if ord < 0 || ord > size
        as_array[ord]
      end

      private

      def by_key
        @by_key ||= {}
      end

      def by_value
        @by_value ||= {}
      end

      def as_array
        @as_array ||= []
      end

      def valid_key_and_value(instance)
        key = instance.key
        value = instance.value
        if (found = find_by_key(key))
          fail NameError, "#{name}::#{key} already exists" unless value == found.value
          warn("ignoring redeclaration of #{name}::#{key} with value #{value} (source: #{caller[4]})")
          nil
        else
          fail NameError, "A #{name} instance with value '#{value}' already exists" if find_by_value(value)
          [key, value]
        end
      end

      def register(instance)
        key, value = valid_key_and_value(instance)
        return unless key && value

        const_set(key.to_s, instance)
        by_key[key] = instance
        by_value[value] = instance
        as_array << instance
      end
    end

    # The symbol key for the enum instance
    attr_reader :key
    # The value encapsulated by the enum instance
    attr_reader :value
    # The ordinal of the enum instance, in declaration order
    attr_reader :ord

    # Compares two instances of the same enum class based on their declaration order
    def <=>(other)
      ord <=> other.ord if self.class == other.class
    end

    # Generates a Fixnum hash value for this enum instance
    def hash
      @hash ||= begin
        result = 17
        result = 31 * result + self.class.hash
        result = 31 * result + ord
        result.is_a?(Fixnum) ? result : result.hash
      end
    end

    private

    def initialize(key, value = nil, &block)
      fail TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
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
