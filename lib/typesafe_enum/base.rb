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

      # Looks up an enum instance based on its ordinal
      def find_by_ord(ord)
        return nil if ord < 0 || ord > size
        as_array[ord]
      end

      private

      attr_accessor :by_key
      attr_accessor :by_value
      attr_accessor :as_array

      def undefine_class
        enclosing_module = Module.nesting.last
        class_value = name.split('::').last || ''
        enclosing_module.send(:remove_const, class_value)
      end

      def register(instance)
        ensure_registries
        key, value = valid_key_and_value(instance)

        by_key[key] = instance
        by_value[value] = instance
        as_array << instance
        const_set(key.to_s, instance)
      end

      def ensure_registries
        self.by_key ||= {}
        self.by_value ||= {}
        self.as_array ||= []
      end

      def valid_key_and_value(instance)
        key = instance.key
        value = instance.value

        begin
          fail NameError, "#{name}::#{key} already exists" if find_by_key(key)
          fail NameError, "A #{name} instance with value '#{value}' already exists" if find_by_value(value)
        rescue NameError => e
          undefine_class
          raise e
        end

        [key, value]
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

    def initialize(key, value = nil)
      fail TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
      @key = key
      @value = value || key.to_s.downcase
      @ord = self.class.size
      self.class.class_exec(self) do |instance|
        register(instance)
      end
    end

    private_class_method :new

  end
end
