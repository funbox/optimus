# Changelog

## 0.4.0 (Unreleased)

### Added
- Added module documentation for all major modules
- Added typespecs for structs and functions
- Added GitHub Actions CI workflow
- Added Dependabot configuration
- Added formatter configuration
- Added Credo static code analysis tool
- Added doctests and examples

### Changed
- Updated Elixir compatibility to support 1.10 through 1.19
- Modernized mix.exs structure and dependency versions
- Moved `preferred_cli_env` from `project/0` to `cli/0` function (Elixir 1.19)
- Converted struct update syntax to map update syntax for Elixir 1.19 type safety
- Renamed `applications` to `extra_applications` in mix.exs
- Updated struct definitions to use key-value pairs with defaults
- Fixed deprecation warnings for String.slice with negative index
- Improved type definitions
- Updated Config module usage in config.exs
- Updated GitHub Actions workflow to use latest actions and test on Elixir 1.18.3
- Modernized function implementations using Elixir 1.10+ features
- Replaced regex-based string operations with more efficient String functions
- Improved error messages and validation

## 0.3.0

- Version bump to handle new releases

## 0.2.1

### Changed
- Fix for `String.to_boolean` deprecation warning

## 0.2.0

### Changed
- Fix typespec for `Optimus.new/1`
- Fixed wrong link to travis badge

## 0.1.4

### Added
- Support for Elixir ~> 1.3

## 0.1.3 

### Added
- Added help command without subcommand (`optimus help`)

## 0.1.2 

### Added
- Added usage help (`statcalc help <commandname>`)

## 0.1.1

### Added
- Better help message formatting

## 0.1.0

### Added
- Initial release