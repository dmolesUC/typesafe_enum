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
