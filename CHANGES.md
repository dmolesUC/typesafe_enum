## 0.1.4

- Exact duplicate instances (e.g. due to multiple `requires`) are now ignored with a warning,
  instead of causing a `NameError`. Duplicate keys with different values, and duplicate values
  with different keys, still raise a `NameError`.
- `NameErrors` due to invalid keys or values no longer cause the enum class to be undefined.
  However, the invalid instances will still not be registered and no constants created for them.

## 0.1.3

- Fixed issue where invalid classes weren't properly removed after duplicate name declarations,
  polluting the namespace and causing duplicate declration error messages to be lost.

## 0.1.2

- Fixed issue where `::find_by_value_str` failed to return `nil` for bad values

## 0.1.1

- Added `::find_by_value_str`

## 0.1.0

- Initial release
