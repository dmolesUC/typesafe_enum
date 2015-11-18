module TypesafeEnum
  class Base
    include Comparable

    class << self

      def to_a
        as_array.dup
      end

      def size
        as_array ? as_array.length : 0
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

      def find_by_key(key)
        by_key[key]
      end

      def find_by_name(name)
        by_name[name]
      end

      def find_by_ord(ord)
        return nil if ord < 0 || ord > size
        as_array[ord]
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

      def register(instance)
        ensure_registries
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
          fail NameError, "#{self.name}::#{key} already exists" if find_by_key(key)
          fail NameError, "A #{self.name} instance with name '#{name}' already exists" if find_by_name(name)
        rescue NameError => e
          undefine_class
          raise e
        end

        [key, name]
      end

    end

    attr_reader :key
    attr_reader :name
    attr_reader :ord

    def <=>(other)
      ord <=> other.ord if self.class == other.class
    end

    def hash
      @hash ||= begin
        result = 17
        result = 31 * result + self.class.hash
        result = 31 * result + ord
        result
      end
    end

    private

    def initialize(key, name = nil)
      fail TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
      @key = key
      @name = name || key.to_s.downcase
      @ord = self.class.size
      self.class.class_exec(self) do |instance|
        register(instance)
      end
    end

    private_class_method :new

  end
end
