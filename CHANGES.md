## 0.3.0 (next)

- Update author email in gemspec
- Update RuboCop to version 0.91 and pin version
- Set minimum required_ruby_version to 2.6.0
- Bump .ruby-version to 2.6.6

## 0.2.2 (23 April 2020)

- Implement [`Enumerable`](https://ruby-doc.org/core-2.6.5/Enumerable.html)

## 0.2.1 (12 March 2020)

- Update to Rake 12.3.3

## 0.2.0 (12 March 2020)

- Update to Ruby 2.6.5
- Update to Rake 10.4
- Update to RSpec 3.9
- Update to RuboCop 0.80

## 0.1.8 (22 December 2017)

- Update to Ruby 2.4.1
- Update to rspec 3.7
- Update to RuboCop 0.52
- Update to Yard 0.9.12

## 0.1.7 (28 April 2016)

- The default `to_s` for `TypesafeEnum::Base` now includes the enum's class, key, value,
  and ordinal, e.g.

      Suit::DIAMONDS.to_s
      # => "Suit::DIAMONDS [1] -> diamonds"

  (Fixes [#5](https://github.com/dmolesUC3/typesafe_enum/issues/5).)
- `::find_by_value_str` now uses a hash lookup like the other `::find_by` methods.
- Improved method documentation.

## 0.1.6 (15 Mar 2016)

- [#3](https://github.com/dmolesUC3/typesafe_enum/pull/3) - No need for `instance_eval`
  when creating new enum instance methods - [@dblock](https://github.com/dblock).

## 0.1.5 (27 Jan 2016)

- Include the original call site in the warning message for duplicate instances to help
  with debugging.
- Modified gemspec to take into account SSH checkouts when determining the homepage URL.

## 0.1.4 (18 Dec 2015))

- Exact duplicate instances (e.g. due to multiple `requires`) are now ignored with a warning,
  instead of causing a `NameError`. Duplicate keys with different values, and duplicate values
  with different keys, still raise a `NameError`.
- `NameErrors` due to invalid keys or values no longer cause the enum class to be undefined.
  However, the invalid instances will still not be registered and no constants created for them.

## 0.1.3 (17 Dec 2015)

- Fixed issue where invalid classes weren't properly removed after duplicate name declarations,
  polluting the namespace and causing duplicate declration error messages to be lost.

## 0.1.2 (19 Nov 2015)

- Fixed issue where `::find_by_value_str` failed to return `nil` for bad values

## 0.1.1 (19 Nov 2015)

- Added `::find_by_value_str`

## 0.1.0 (18 Nov 2015)

- Initial release
