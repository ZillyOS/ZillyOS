# Changelog

All notable changes to ZillyOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup and configuration
- Core architecture documentation
- Development environment setup scripts
- Continuous integration pipeline
- Dependency management strategy
- Documentation infrastructure

## [0.1.0] - 2025-05-22

### Added
- Initial repository structure
- Basic TypeScript configuration
- Essential development tooling
- Core runtime architecture
- Documentation templates and standards
- GitHub Actions workflows for CI
- Development server with hot reloading
- API documentation generation
- Dependency management tools and policies
- Contribution guidelines and templates

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- Dependency vulnerability scanning
- Security policy and disclosure process
- Automated security checks in CI pipeline

## How to Update the Changelog

When making changes to the project, add an entry to the "Unreleased" section following these guidelines:

1. Add one bullet point per change
2. Group changes by type: Added, Changed, Deprecated, Removed, Fixed, Security
3. Be specific but concise
4. Reference issue numbers where applicable (e.g., "Fixed memory leak in event handler (#123)")
5. Include migration notes for breaking changes

When releasing a new version:

1. Move entries from "Unreleased" to a new version section
2. Add the release date
3. Create a new empty "Unreleased" section
4. Update version numbers in package.json and other relevant files 