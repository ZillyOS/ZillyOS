# ZillyOS Versioning Strategy

ZillyOS follows Semantic Versioning (SemVer) principles for version numbering.

## Version Format

The version format is:

```
MAJOR.MINOR.PATCH-BRANCH
```

Where:
- **MAJOR**: Incremented for incompatible API changes
- **MINOR**: Incremented for backward-compatible functionality additions
- **PATCH**: Incremented for backward-compatible bug fixes
- **BRANCH**: The development branch (e.g., feature/project-setup, develop, staging)

## Versioning Rules

1. Each completed mission represents a MINOR version update
2. Each completed mission subtask represents a PATCH version update
3. MAJOR version updates are reserved for significant API changes or architecture overhauls
4. Branch identifier changes based on the current development branch

## Version File

The version is tracked in the `.project/version.txt` file and should be updated with each completed task or subtask according to the rules above.

## Releases

- Pre-release versions are identified by the branch name (e.g., `0.1.0-develop`)
- Release candidates use the `-rc.N` suffix (e.g., `1.0.0-rc.1`)
- Stable releases do not include a branch identifier (e.g., `1.0.0`) 