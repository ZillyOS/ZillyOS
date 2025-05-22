# ZillyOS Peer Dependency Policy

This document outlines our approach to managing peer dependencies in the ZillyOS project. Peer dependencies represent dependencies that the consuming application is expected to provide.

## What are Peer Dependencies?

Peer dependencies are packages that are expected to be provided by the consuming application rather than being bundled with the package itself. They are declared in the `peerDependencies` section of the `package.json` file.

Common examples include:
- Core framework libraries (React, Angular, etc.)
- Shared utilities (lodash, moment, etc.)
- UI component libraries

## When to Use Peer Dependencies

Use peer dependencies when:

1. **Avoiding Duplicate Installations**: The dependency should only be installed once in the project
2. **Version Compatibility**: The package works with a range of versions of the dependency
3. **Plugin System**: Your package extends or modifies functionality of another package

## ZillyOS Peer Dependency Guidelines

### Declaration in package.json

Peer dependencies should be declared in the `package.json` file with appropriate version ranges:

```json
{
  "name": "@zillyzoo/component-library",
  "version": "1.0.0",
  "peerDependencies": {
    "react": "^17.0.0 || ^18.0.0",
    "react-dom": "^17.0.0 || ^18.0.0"
  }
}
```

### Version Ranges

When specifying version ranges for peer dependencies:

1. **Be as Permissive as Possible**: Allow the widest range of versions that your package works with
2. **Test Against Boundaries**: Ensure your package works with both minimum and maximum supported versions
3. **Document Compatibility**: Clearly document any known issues with specific versions

### Optional Peer Dependencies

For dependencies that enhance functionality but aren't required:

```json
{
  "peerDependencies": {
    "optional-package": "^2.0.0"
  },
  "peerDependenciesMeta": {
    "optional-package": {
      "optional": true
    }
  }
}
```

## Testing Peer Dependencies

### Testing Strategy

1. **Matrix Testing**: Test against multiple versions of peer dependencies
2. **CI Integration**: Configure CI to test against different peer dependency versions
3. **Boundary Testing**: Always test against the minimum and maximum supported versions

### Test Setup Example

```yml
# GitHub Actions example for testing multiple React versions
jobs:
  test:
    strategy:
      matrix:
        react-version: [16.14.0, 17.0.2, 18.0.0]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '16'
      - run: npm install
      - run: npm install react@${{ matrix.react-version }} react-dom@${{ matrix.react-version }}
      - run: npm test
```

## Troubleshooting Peer Dependencies

### Common Issues

1. **Missing Peer Dependencies**: Warn users to install missing peer dependencies
2. **Version Mismatches**: Document how to resolve version conflicts
3. **Incompatible Updates**: Provide migration guides when peer dependency compatibility changes

### Resolution Strategies

1. **Clear Error Messages**: Provide actionable error messages when peer dependencies are missing
2. **Fallback Behavior**: Implement graceful degradation when optional peer dependencies are missing
3. **Version Detection**: Add runtime checks to detect incompatible versions

## Communication and Documentation

### Documenting Peer Dependencies

1. **README**: List all peer dependencies with version requirements in the README
2. **Installation Guide**: Provide clear installation instructions including peer dependencies
3. **Changelog**: Document changes to peer dependency requirements in the changelog

### Example README Section

```markdown
## Installation

Install the package along with its peer dependencies:

```bash
npm install @zillyzoo/component-library
npm install react@^18.0.0 react-dom@^18.0.0
```

## Peer Dependencies

This package requires the following peer dependencies:

- React ^17.0.0 || ^18.0.0
- React DOM ^17.0.0 || ^18.0.0
```

## Upgrading Peer Dependencies

### Upgrade Strategy

1. **Maintain Backward Compatibility**: When possible, maintain compatibility with older versions
2. **Major Version Bumps**: Increase your package's major version when dropping support for older peer dependency versions
3. **Migration Guides**: Provide migration guides when peer dependency requirements change

### Deprecation Process

1. **Warning Phase**: Emit deprecation warnings before removing support for older versions
2. **Documentation**: Update documentation to clearly indicate upcoming changes to peer dependencies
3. **Timeline Communication**: Provide a clear timeline for deprecation and removal 