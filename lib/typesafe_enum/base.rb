module TypesafeEnum
  class Base
    include Comparable

    class << self
      @@_by_key = {}
      @@_by_name = {}
      @@_as_array = []

      def [](lookup)
        return @@_by_key[lookup] if lookup.is_a?(Symbol)
        return @@_as_array[lookup] if lookup.is_a?(Integer)
        @@_by_name[lookup]
      end

      private

      def undefine_class
        enclosing_module = Module.nesting.last
        class_name = name.split('::').last || ''
        enclosing_module.send(:remove_const, class_name)
      end

      def define(key, name = nil)
        instance = new(key, name)
        k, n = instance.key, instance.name

        if self[k]
          undefine_class
          fail NameError, "#{self.name}::#{k} already exists" if self[k]
        end

        if self[n]
          undefine_class
          fail NameError, "A #{self.name} instance with name '#{n}' already exists" if self[n]
        end

        @@_by_key[k] = instance
        @@_by_name[n] = instance
        self.const_set(key.to_s, instance)
      end

    end

    attr_reader :key
    attr_reader :name

    private

    def initialize(key, name)
      raise TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
      @key = key
      @name = name || key.to_s.downcase
    end

  end
end
