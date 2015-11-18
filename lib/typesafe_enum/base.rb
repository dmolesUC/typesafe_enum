module TypesafeEnum
  class Base
    include Comparable

    class << self

      def [](lookup)
        result = by_key[lookup]
        return result if result

        result = by_name[lookup]
        return result if result

        as_array[lookup] if lookup.is_a?(Integer)
      end

      def to_a
        as_array.dup
      end

      def length
        as_array.length
      end

      def each(&block)
        to_a.each(&block)
      end

      def each_with_index(&block)
        to_a.each_with_index(&block)
      end

      def map(&block)
        to_a.map(&block)
      end

      private

      attr_accessor :by_key
      attr_accessor :by_name
      attr_accessor :as_array

      def undefine_class
        enclosing_module = Module.nesting.last
        class_name = name.split('::').last || ''
        enclosing_module.send(:remove_const, class_name)
      end

      def define(key, name = nil) # rubocop:disable
        ensure_registries

        instance = new(key, name, as_array.length)
        key, name = valid_key_and_name(instance)

        by_key[key] = instance
        by_name[name] = instance
        as_array << instance
        const_set(key.to_s, instance)
      end

      def ensure_registries
        self.by_key ||= {}
        self.by_name ||= {}
        self.as_array ||= []
      end

      def valid_key_and_name(instance)
        key = instance.key
        name = instance.name

        begin
          fail NameError, "#{self.name}::#{key} already exists" if self[key]
          fail NameError, "A #{self.name} instance with name '#{name}' already exists" if self[name]
        rescue NameError
          undefine_class
          raise
        end

        [key, name]
      end

    end

    attr_reader :key
    attr_reader :name
    attr_reader :ordinal

    def <=>(other)
      ordinal <=> other.ordinal if self.class == other.class
    end

    def hash
      @hash ||= begin
        result = 17
        result = 31 * result + self.class.hash
        result = 31 * result + ordinal
        result
      end
    end

    private

    def initialize(key, name, ordinal)
      fail TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
      @key = key
      @name = name || key.to_s.downcase
      @ordinal = ordinal
    end

  end
end
