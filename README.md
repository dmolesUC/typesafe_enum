# typesafe_enum

[![Build Status](https://travis-ci.org/dmolesUC3/typesafe_enum.png?branch=master)](https://travis-ci.org/dmolesUC3/typesafe_enum)
[![Code Climate](https://codeclimate.com/github/dmolesUC3/typesafe_enum.png)](https://codeclimate.com/github/dmolesUC3/typesafe_enum)
[![Inline docs](http://inch-ci.org/github/dmolesUC3/typesafe_enum.png)](http://inch-ci.org/github/dmolesUC3/typesafe_enum)
[![Gem Version](https://img.shields.io/gem/v/typesafe_enum.svg)](https://github.com/dmolesUC3/typesafe_enum/releases)

A Ruby implementation of Joshua Bloch's
[typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums),
with syntax loosely inspired by [Ruby::Enum](https://github.com/dblock/ruby-enum).

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

A constant is declared for each instance, with the key symbol as its
name:

```ruby
Suit::CLUBS
# => #<Suit:0x007fe9b3ba2698 @key=:CLUBS, @name="clubs", @ord=0>
```

By default, the `name` of an instance is its `key` symbol, lowercased:

```ruby
Suit::CLUBS.key
# => :CLUBS
Suit::CLUBS.name
# => 'clubs'
```

But you can also new an explicit `name`:

```ruby
class Tarot < TypesafeEnum::Base
  new :CUPS, 'Cups'
  new :COINS, 'Coins'
  new :WANDS, 'Wands'
  new :SWORDS, 'Swords'
end

Tarot::CUPS.name
# => 'Cups'
```

And `names` need not be strings:

```ruby
class Scale < TypesafeEnum::Base
  new :DECA, 10
  new :HECTO, 100
  new :KILO, 1_000
  new :MEGA, 1_000_000
end

Scale::KILO.name
# => 1000
```

Enum instances have an ordinal value corresponding to their declaration
order:

```ruby
Suit::SPADES.ord
# => 3
```

And enum instances are comparable based on that order:

```ruby
Suit::SPADES > Suit::DIAMONDS
# => true
```

## Convenience methods on enum classes

### `::to_a`

Returns an array of the enum instances in declaration order:

```ruby
Tarot.to_a
# => [#<Tarot:0x007fd4db30eca8 @key=:CUPS, @name="Cups", @ord=0>, #<Tarot:0x007fd4db30ebe0 @key=:COINS, @name="Coins", @ord=1>, #<Tarot:0x007fd4db30eaf0 @key=:WANDS, @name="Wands", @ord=2>, #<Tarot:0x007fd4db30e9b0 @key=:SWORDS, @name="Swords", @ord=3>]
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
Suit.each { |s| puts s.name }
# clubs
# diamonds
# hearts
# spades

Suit.each_with_index { |s, i| puts "#{i}: #{s.key}" }
# 0: CLUBS
# 1: DIAMONDS
# 2: HEARTS
# 3: SPADES

Suit.map(&:name)
# => ["clubs", "diamonds", "hearts", "spades"]
```

### `::find_by_key`, `::find_by_name`, `::find_by_ord`

Look up an enum instance based on its key, name, or ordinal:

```ruby
Tarot.find_by_key(:CUPS)
# => #<Tarot:0x007faab19fda40 @key=:CUPS, @name="Cups", @ord=0>
Tarot.find_by_name('Wands')
# => #<Tarot:0x007faab19fd8b0 @key=:WANDS, @name="Wands", @ord=2>
Tarot.find_by_ord(3)
# => #<Tarot:0x007faab19fd810 @key=:SWORDS, @name="Swords", @ord=3>
```

## Enum classes with methods

Enum classes can have methods, and other non-enum constants:

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

*[TODO: simple syntax for adding methods to instances]*

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
[design pattern]((http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums))
and later as a
[first-class language construct](https://docs.oracle.com/javase/1.5.0/docs/guide/language/enums.html).
In Java, an `Enum` class news a closed, named set of _instances of that class,_ rather than
of a primitive type such as an `int`, and those instances have all the features of other objects,
such as methods, fields, and type membership. Likewise, a `TypesafeEnum` class news a named set
of instances of that class, rather than of a set of some other type.

```ruby
Suit::CLUBS.is_a?(Suit)
# => true
Tarot::CUPS == 'Cups'
# => false
```

## How is this different from [java.lang.Enum](http://docs.oracle.com/javase/8/docs/api/java/lang/Enum.html)?

*[TODO: details]*

### Clunkier syntax

### No special `switch`/`case` support

### No serialization support

  - but `#==`, `#hash` etc. are `Marshal`-safe

### No support classes like [`EnumSet`](http://docs.oracle.com/javase/8/docs/api/java/util/EnumSet.html) and
  [`EnumMap`](http://docs.oracle.com/javase/8/docs/api/java/util/EnumMap.html)

### Enum classes are not closed

It's Ruby, so even though `:new` is private to each enum class, you
can always work around that:

```ruby
Suit.send(:new, :JOKERS)
# => #<Suit:0x007fc9e44e4778 @key=:JOKERS, @name="jokers", @ord=4>
Suit.map(&:key)
# => [:CLUBS, :DIAMONDS, :HEARTS, :SPADES, :JOKERS]
Suit.size
# => 5
```

### *[Other limitations...]*
