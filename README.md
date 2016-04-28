# TypesafeEnum

[![Build Status](https://travis-ci.org/dmolesUC3/typesafe_enum.svg?branch=master)](https://travis-ci.org/dmolesUC3/typesafe_enum)
[![Code Climate](https://codeclimate.com/github/dmolesUC3/typesafe_enum.svg)](https://codeclimate.com/github/dmolesUC3/typesafe_enum)
[![Inline docs](http://inch-ci.org/github/dmolesUC3/typesafe_enum.svg)](http://inch-ci.org/github/dmolesUC3/typesafe_enum)
[![Gem Version](https://img.shields.io/gem/v/typesafe_enum.svg)](https://github.com/dmolesUC3/typesafe_enum/releases)

A Ruby implementation of Joshua Bloch's
[typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums),
with syntax loosely inspired by [Ruby::Enum](https://github.com/dblock/ruby-enum).

## Table of contents

- [Basic usage](#basic-usage)
- [Ordering](#ordering)
- [String representations](#string-representations)
- [Convenience methods on enum classes](#convenience-methods-on-enum-classes)
    - [::to\_a](#to_a)
    - [::size](#size)
    - [::each, ::each\_with\_index, and ::map](#each-each_with_index-and-map)
    - [::find\_by\_key, ::find\_by\_value, ::find\_by\_ord](#find_by_key-find_by_value-find_by_ord)
    - [::find\_by\_value\_str](#find_by_value_str)
- [Enum classes with methods](#enum-classes-with-methods)
- [Enum instances with methods](#enum-instances-with-methods)
- [How is this different from Ruby::Enum?](#how-is-this-different-from-rubyenum)
- [How is this different from java.lang.Enum?](#how-is-this-different-from-javalangenum)
    - [Clunkier syntax](#clunkier-syntax)
    - [No special switch/case support](#no-special-switchcase-support)
    - [No serialization support](#no-serialization-support)
    - [No support classes](#no-support-classes)
    - [Enum classes are not closed](#enum-classes-are-not-closed)
- [Contributing](#contributing)

## Basic usage

Create a new enum class and a set of instances:

```ruby
require 'typesafe_enum'

class Suit < TypesafeEnum::Base
  new :CLUBS
  new :DIAMONDS
  new :HEARTS
  new :SPADES
end
```

A constant is declared for each instance, with an instance of the new
class as the value of that constant:

```ruby
Suit::CLUBS
# => #<Suit:0x007fe9b3ba2698 @key=:CLUBS, @value="clubs", @ord=0>
```

By default, the `value` of an instance is its `key` symbol, lowercased:

```ruby
Suit::CLUBS.key
# => :CLUBS
Suit::CLUBS.value
# => 'clubs'
```

But you can also declare an explicit `value`:

```ruby
class Tarot < TypesafeEnum::Base
  new :CUPS, 'Cups'
  new :COINS, 'Coins'
  new :WANDS, 'Wands'
  new :SWORDS, 'Swords'
end

Tarot::CUPS.value
# => 'Cups'
```

And `values` need not be strings:

```ruby
class Scale < TypesafeEnum::Base
  new :DECA, 10
  new :HECTO, 100
  new :KILO, 1_000
  new :MEGA, 1_000_000
end

Scale::KILO.value
# => 1000
```

Declaring two instances with the same key will produce an error:

```ruby
class Suit < TypesafeEnum::Base
  new :CLUBS
  new :DIAMONDS
  new :HEARTS
  new :SPADES
  new :SPADES, '♠'
end
```

```
typesafe_enum/lib/typesafe_enum/base.rb:88:in `valid_key_and_value': Suit::SPADES already exists (NameError)
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:98:in `register'
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:138:in `block in initialize'
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:137:in `class_exec'
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:137:in `initialize'
	from ./scratch.rb:11:in `new'
	from ./scratch.rb:11:in `<class:Suit>'
	from ./scratch.rb:6:in `<main>'
```

Likewise two instances with the same value but different keys:

```ruby
class Tarot < TypesafeEnum::Base
  new :CUPS, 'Cups'
  new :COINS, 'Coins'
  new :WANDS, 'Wands'
  new :SWORDS, 'Swords'
  new :STAVES, 'Wands'
end
```

```
/typesafe_enum/lib/typesafe_enum/base.rb:92:in `valid_key_and_value': A Tarot instance with value 'Wands' already exists (NameError)
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:98:in `register'
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:138:in `block in initialize'
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:137:in `class_exec'
	from /Users/dmoles/Work/Stash/typesafe_enum/lib/typesafe_enum/base.rb:137:in `initialize'
	from ./scratch.rb:11:in `new'
	from ./scratch.rb:11:in `<class:Tarot>'
	from ./scratch.rb:6:in `<main>'
```

However, declaring an identical key/value pair will be ignored with a warning, to avoid unnecessary errors
when, e.g., a declaration file is accidentally loaded twice.

```ruby
class Tarot < TypesafeEnum::Base
  new :CUPS, 'Cups'
  new :COINS, 'Coins'
  new :WANDS, 'Wands'
  new :SWORDS, 'Swords'
end

class Tarot < TypesafeEnum::Base
  new :CUPS, 'Cups'
  new :COINS, 'Coins'
  new :WANDS, 'Wands'
  new :SWORDS, 'Swords'
end

# => ignoring redeclaration of Tarot::CUPS with value Cups (source: /tmp/duplicate_enum.rb:13:in `new')
# => ignoring redeclaration of Tarot::COINS with value Coins (source: /tmp/duplicate_enum.rb:14:in `new')
# => ignoring redeclaration of Tarot::WANDS with value Wands (source: /tmp/duplicate_enum.rb:15:in `new')
# => ignoring redeclaration of Tarot::SWORDS with value Swords (source: /tmp/duplicate_enum.rb:16:in `new')
```

**Note:** If do you see these warnings, it probably means there's something wrong with your `$LOAD_PATH` (e.g.,
the same directory present both via its real path and via a symlink). This can cause all sorts of problems,
and Ruby's `require` statement is [known to be not smart enough to deal with it](https://bugs.ruby-lang.org/issues/4403),
so it's worth tracking down and fixing the root cause.

## Ordering

Enum instances have an ordinal value corresponding to their declaration
order:

```ruby
Suit::SPADES.ord
# => 3
```

And enum instances are comparable (within a type) based on that order:

```ruby
Suit::SPADES.is_a?(Comparable)
# => true
Suit::SPADES > Suit::DIAMONDS
# => true
Suit::SPADES > Tarot::CUPS
# ArgumentError: comparison of Suit with Tarot failed
```

## String representations

The default `to_s` implementation provides the enum's class, key, value,
and ordinal, e.g.

```ruby
Suit::DIAMONDS.to_s
# => "Suit::DIAMONDS [1] -> diamonds"
```

It can of course be overridden.

## Convenience methods on enum classes

### `::to_a`

Returns an array of the enum instances in declaration order:

```ruby
Tarot.to_a
# => [#<Tarot:0x007fd4db30eca8 @key=:CUPS, @value="Cups", @ord=0>, #<Tarot:0x007fd4db30ebe0 @key=:COINS, @value="Coins", @ord=1>, #<Tarot:0x007fd4db30eaf0 @key=:WANDS, @value="Wands", @ord=2>, #<Tarot:0x007fd4db30e9b0 @key=:SWORDS, @value="Swords", @ord=3>]
```

### `::size`

Returns the number of enum instances:

```ruby
Suit.size
# => 4
```

### `::each`, `::each_with_index`, and `::map`

Iterate over the set of enum instances:

```ruby
Suit.each { |s| puts s.value }
# clubs
# diamonds
# hearts
# spades

Suit.each_with_index { |s, i| puts "#{i}: #{s.key}" }
# 0: CLUBS
# 1: DIAMONDS
# 2: HEARTS
# 3: SPADES

Suit.map(&:value)
# => ["clubs", "diamonds", "hearts", "spades"]
```

### `::find_by_key`, `::find_by_value`, `::find_by_ord`

Look up an enum instance based on its key, value, or ordinal:

```ruby
Tarot.find_by_key(:CUPS)
# => #<Tarot:0x007faab19fda40 @key=:CUPS, @value="Cups", @ord=0>
Tarot.find_by_value('Wands')
# => #<Tarot:0x007faab19fd8b0 @key=:WANDS, @value="Wands", @ord=2>
Tarot.find_by_ord(3)
# => #<Tarot:0x007faab19fd810 @key=:SWORDS, @value="Swords", @ord=3>
```

### `::find_by_value_str`

Look up an enum instance based on the string form of its value (as returned by `to_s`) --
useful for, e.g., XML or JSON mapping of enums with non-string values:

```ruby
Scale.find_by_value_str('1000000')
# => #<Scale:0x007f8513a93810 @key=:MEGA, @value=1000000, @ord=3>
```

## Enum classes with methods

Enum classes are just classes. They can have methods, and other non-enum constants.
(The `:initialize` method for each class, though, is declared programmatically by
the base class. If you need to redefine it, be sure to alias and call the original.)

```ruby
class Suit < TypesafeEnum::Base
  new :CLUBS
  new :DIAMONDS
  new :HEARTS
  new :SPADES

  ALL_PIPS = %w(♣ ♦ ♥ ♠)

  def pip
    ALL_PIPS[self.ord]
  end
end

Suit::ALL_PIPS
# => ["♣", "♦", "♥", "♠"]

Suit::CLUBS.pip
# => "♣"

Suit.map(&:pip)
# => ["♣", "♦", "♥", "♠"]
```

## Enum instances with methods

Enum instances can declare their own methods:

```ruby
class Operation < TypesafeEnum::Base
  new(:PLUS, '+') do
    def eval(x, y)
      x + y
    end
  end
  new(:MINUS, '-') do
    def eval(x, y)
      x - y
    end
  end
end

Operation::PLUS.eval(11, 17)
# => 28

Operation::MINUS.eval(28, 11)
# => 17

Operation.map { |op| op.eval(39, 23) }
# => [62, 16]
```

## How is this different from [Ruby::Enum](https://github.com/dblock/ruby-enum)?

[Ruby::Enum](https://github.com/dblock/ruby-enum) is much closer to the classic
[C enumeration](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Enumerations)
as seen in C, [C++](https://msdn.microsoft.com/en-us/library/2dzy4k6e.aspx),
[C#](https://msdn.microsoft.com/en-us/library/sbbt4032.aspx), and
[Objective-C](https://developer.apple.com/library/ios/releasenotes/ObjectiveC/ModernizationObjC/AdoptingModernObjective-C/AdoptingModernObjective-C.html#//apple_ref/doc/uid/TP40014150-CH1-SW6).
In C and most C-like languages, an `enum` is simply a named set of `int` values
(though C++ and others require an explicit cast to assign an `enum` value to
an `int` variable).

Similarly, a `Ruby::Enum` class is simply a named set of values of any type,
with convenience methods for iterating over the set. Usually the values are
strings, but they can be of any type.

```ruby
# String enum
class Foo
  include Ruby::Enum

  new :BAR, 'bar'
  new :BAZ, 'baz'
end

Foo::BAR
#  => "bar"
Foo::BAR == 'bar'
# => true

# Integer enum
class Bar
  include Ruby::Enum

  new :BAR, 1
  new :BAZ, 2
end

Bar::BAR
#  => "bar"
Bar::BAR == 1
# => true
```

Java introduced the concept of "typesafe enums", first as a
[design pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums)
and later as a
[first-class language construct](https://docs.oracle.com/javase/1.5.0/docs/guide/language/enums.html).
In Java, an `Enum` class defines a closed, valued set of _instances of that class,_ rather than
of a primitive type such as an `int`, and those instances have all the features of other objects,
such as methods, fields, and type membership. Likewise, a `TypesafeEnum` class defines a valued set
of instances of that class, rather than of a set of some other type.

```ruby
Suit::CLUBS.is_a?(Suit)
# => true
Tarot::CUPS == 'Cups'
# => false
```

## How is this different from `java.lang.Enum`?

### Clunkier syntax

In Java 5+, you can define an enum in one line and instance-specific methods with a pair of braces.

```java
enum CMYKColor {
  CYAN, MAGENTA, YELLOW, BLACK
}

enum Suit {
  CLUBS    { char pip() { return '♣'; } },
  DIAMONDS { char pip() { return '♦'; } },
  HEARTS   { char pip() { return '♥'; } },
  SPADES   { char pip() { return '♠'; } };

  abstract char pip();
}
```

With `TypesafeEnum`, instance-specific methods require extra parentheses,
as shown above, and about the best you can do even for simple enums is something like:

```ruby
class CMYKColor < TypesafeEnum::Base
  [:CYAN, :MAGENTA, :YELLOW, :BLACK].each { |c| new c }
end
```

### No special `switch`/`case` support

The Java compiler will warn you if a `switch` statement doesn't include all instances of a Java enum.
Ruby doesn't care whether you cover all instances of a `TypesafeEnum`, and in fact it doesn't care if
your `when` statements include a mix of enum instances of different classes, or of enum instances and
other things. (In some respects this latter is a feature, of course.)

### No serialization support

The Java `Enum` class has special code to ensure that enum instances are deserialized to the existing
singleton constants. This can be done with Ruby [`Marshal`](http://ruby-doc.org/core-2.2.3/Marshal.html)
(by defining `marshal_load`) but it didn't seem worth the trouble, so a deserialized `TypesafeEnum` will
not be identical to the original:

```ruby
clubs2 = Marshal.load(Marshal.dump(Suit::CLUBS))
Suit::CLUBS.equal?(clubs2)
# => false
```

However, `#==`, `#hash`, etc. are `Marshal`-safe:

```ruby
Suit::CLUBS == clubs2
# => true
clubs2 == Suit::CLUBS
# => true
Suit::CLUBS.hash == clubs2.hash
# => true
```

If this isn't enough, and the lack of object identity across marshalling is a problem, it could be added
in a later version. (Pull requests welcome!)

### No support classes

Java has `Enum`-specific classes like
[`EnumSet`](http://docs.oracle.com/javase/8/docs/api/java/util/EnumSet.html) and
[`EnumMap`](http://docs.oracle.com/javase/8/docs/api/java/util/EnumMap.html) that provide special
high-performance, optimized versions of its collection interfaces. `TypesafeEnum` doesn't.

### Enum classes are not closed

It's Ruby, so even though `:new` is private to each enum class, you
can work around that in various ways:

```ruby
Suit.send(:new, :JOKERS)
# => #<Suit:0x007fc9e44e4778 @key=:JOKERS, @value="jokers", @ord=4>

class Tarot
  new :MAJOR_ARCANA, 'Major Arcana'
end
# => #<Tarot:0x007f8513b39b20 @key=:MAJOR_ARCANA, @value="Major Arcana", @ord=4>

Suit.map(&:key)
# => [:CLUBS, :DIAMONDS, :HEARTS, :SPADES, :JOKERS]

Tarot.map(&:key)
# => [:CUPS, :COINS, :WANDS, :SWORDS, :MAJOR_ARCANA]
```

## Contributing

Pull requests are welcome, but please make sure the tests pass, the code has 100% coverage, and the
code style passes Rubocop. (The default rake task should check all of these for you.)
