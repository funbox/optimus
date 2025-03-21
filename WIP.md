# Optimus Modernization Plan

## Overview

Optimus is a command-line argument parsing library for Elixir inspired by the Rust library clap.rs. This document outlines recommendations for modernizing the codebase while maintaining backward compatibility with existing APIs.

## Current State

- Elixir compatibility: ~> 1.3 (current Elixir is 1.16+)
- Tests against Elixir 1.9 through 1.14 in CI
- Minimal dependencies: only `:logger` as application dependency
- Travis CI mentioned in README, but GitHub Actions also implemented
- Uses older Elixir syntax and patterns in various places
- Last updated: Version 0.3.0

## Modernization Recommendations

### 1. Elixir Version Updates

- Increase minimum Elixir version to at least 1.10 (while maintaining compatibility)
- Update CI matrix to include Elixir 1.15 and 1.16
- Update OTP compatibility to include OTP 26+

### 2. Project Structure Updates

- Convert from `applications: [:logger]` to `extra_applications: [:logger]` in mix.exs
- Add `.formatter.exs` file with project-specific configuration
- Update links and badges in README from Travis CI to GitHub Actions
- Add Dependabot configuration for automatic dependency updates

### 3. Code Modernization

- Replace list-style struct definitions with explicit key-value pairs
  - Current: `defstruct [:name, :description, ...]`
  - Modern: `defstruct name: nil, description: nil, ...`
- Update TypeSpec definitions to use more modern syntax
- Add `@impl` annotations for protocol implementations
- Replace deprecated functions and patterns
- Convert conditional code in `ex_doc_version/0` to function clauses
- Replace guard clauses with pattern matching where appropriate
- Use module attributes more consistently
- Refactor long functions into smaller, more focused ones

### 4. Add New Modern Features (With Backward Compatibility)

- Add support for structured typespecs with opaque types
- Add doctests for better documentation and testing
- Add more specific parser types (boolean, enum, etc.)
- Improve error messages and validation
- Add telemetry instrumentation for performance monitoring
- Add keyword arguments support for builder functions while maintaining list compatibility

### 5. Dependency Updates

- Update excoveralls to the latest version (~> 0.5 is very old)
- Add formatting tools and static analysis
- Consider adding Credo for code quality enforcement

### 6. Testing Improvements

- Add more unit tests to ensure backward compatibility
- Add property-based tests for parsing functions
- Test against current Elixir/OTP versions
- Add doctests for examples in documentation

### 7. Documentation Improvements

- Update documentation to reflect modern Elixir practices
- Improve typespecs to be more specific
- Add more examples demonstrating usage patterns
- Create a migration guide for users updating from older versions

### 8. CI/CD Improvements

- Update GitHub workflow to use more recent Ubuntu runners
- Add static code analysis tools
- Add automatic formatting checks
- Add automatic publishing to Hex on release

## Implementation Strategy

The recommended approach for implementation is:

1. Create a staging branch for modernization work
2. Update project configuration first (mix.exs, CI config, etc.)
3. Add a formatter configuration and format all code
4. Implement modern Elixir features while maintaining API compatibility
5. Add deprecation warnings for any planned future changes
6. Thoroughly test against all supported Elixir versions
7. Update documentation and examples

## Backward Compatibility Considerations

- All public functions should maintain their signatures
- New features should be opt-in through additional parameters
- Add deprecation warnings for features that might change in future versions
- Ensure tests cover all existing functionality to prevent regressions
