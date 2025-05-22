# ZillyOS Branching Strategy

## Branch Structure

ZillyOS uses a structured branching model to manage development, testing, and releases:

### Main Branches

- **`main`**: The main branch contains only releases that have been thoroughly tested and are production-ready.
- **`develop`**: The development branch is where all feature branches are merged and is the primary integration branch.
- **`staging`**: The staging branch is used for testing and validation before merging to main.

### Feature Branches

- **`feature/mission-XX`**: Feature branches are created for each mission and branched from `develop`.
- **`feature/mission-XX-component`**: Sub-feature branches may be created for complex features within a mission.

### Hotfix Branches

- **`hotfix/description`**: Hotfix branches are created from `main` to address critical issues in production.

## Workflow

1. **Feature Development**:
   - Create a feature branch from `develop`
   - Implement and test the feature
   - Create a pull request to merge back to `develop`
   - After code review, merge to `develop`

2. **Release Process**:
   - Merge `develop` into `staging` for integration testing
   - Perform testing in the `staging` environment
   - Once validated, merge `staging` into `main`

3. **Hotfix Process**:
   - Create a hotfix branch from `main`
   - Implement and test the fix
   - Create pull requests to merge to both `main` and `develop`

## Commit Message Conventions

ZillyOS follows the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation changes
- **style**: Changes that do not affect code functionality (formatting, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **test**: Adding or updating tests
- **chore**: Changes to the build process or auxiliary tools

### Scope

The scope should be the name of the module or component affected by the change.

### Examples

```
feat(auth): add JWT authentication
fix(api): correct response status code
docs(readme): update installation instructions
```

## Pull Request Guidelines

1. **Title**: Follow the same format as commit messages
2. **Description**: Include a detailed description of changes
3. **Linked Issues**: Reference related issues
4. **Reviewers**: Assign at least one reviewer
5. **Tests**: Ensure all tests pass
6. **Documentation**: Update documentation as needed

## Branch Protection Rules

- `main` and `develop` branches are protected
- Direct pushes to protected branches are not allowed
- Pull requests require at least one approval
- Status checks must pass before merging
- Branches must be up to date before merging 