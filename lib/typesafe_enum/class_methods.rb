module TypesafeEnum
  # Class methods for {{TypesafeEnum::Base}}.
  module ClassMethods
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

    # Looks up an enum instance based on its value
    # @param value [Object] the value to look up
    # @return [self, EnumValidationError] the corresponding enum instance, or throws #EnumValidationError
    def find_by_value!(value)
      valid = find_by_value(value)
      return valid unless valid.nil?

      raise Exceptions::EnumValidationError, "#{class_name}: #{value} is absurd"
    end

    # Looks up an enum instance based on the string representation of its value
    # @param value_str [String] the string form of the value
    # @return [self, nil] the corresponding enum instance, or nil
    def find_by_value_str(value_str)
      value_str = value_str.to_s
      by_value_str[value_str]
    end

    # Looks up an enum instance based on the string representation of its value
    # @param value_str [String] the string form of the value
    # @return [self, EnumValidationError] the corresponding enum instance, or throws #EnumValidationError
    def find_by_value_str!(value_str)
      valid = find_by_value_str(value_str)
      return valid unless valid.nil?

      raise Exceptions::EnumValidationError, "#{class_name}: #{value_str} is absurd"
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

    # Returns the demodulized class name of the inheriting class
    # @return [String] The demodulized class name
    def class_name
      name.split('::').last
    end

  end
end
