module TypesafeEnum
  class Base
    include Comparable

    class << self

      def [](lookup)
        return by_key[lookup] if lookup.is_a?(Symbol)
        return as_array[lookup] if lookup.is_a?(Integer)
        by_name[lookup]
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

      private

      attr_accessor :by_key
      attr_accessor :by_name
      attr_accessor :as_array

      def undefine_class
        enclosing_module = Module.nesting.last
        class_name = name.split('::').last || ''
        enclosing_module.send(:remove_const, class_name)
      end

      def define(key, name = nil)
        self.by_key ||= {}
        self.by_name ||= {}
        self.as_array ||= []

        instance = new(key, name, as_array.length)
        k, n = instance.key, instance.name

        if self[k]
          undefine_class
          fail NameError, "#{self.name}::#{k} already exists" if self[k]
        end

        if self[n]
          undefine_class
          fail NameError, "A #{self.name} instance with name '#{n}' already exists" if self[n]
        end

        by_key[k] = instance
        by_name[n] = instance
        as_array << instance
        self.const_set(key.to_s, instance)
      end

    end

    attr_reader :key
    attr_reader :name
    attr_reader :ordinal

    def <=>(value)
      self.ordinal <=> value.ordinal if self.class == value.class
    end

    private

    def initialize(key, name, ordinal)
      raise TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
      @key = key
      @name = name || key.to_s.downcase
      @ordinal = ordinal
    end

  end
end
