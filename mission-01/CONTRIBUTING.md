# Contributing to ZillyOS

Thank you for your interest in contributing to ZillyOS! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by the [ZillyOS Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [conduct@zillyzoo.com](mailto:conduct@zillyzoo.com).

## Getting Started

### Prerequisites

- Node.js (version 18 or higher)
- npm or yarn
- Git

### Setup

1. Fork the repository
2. Clone your fork:
   ```
   git clone https://github.com/your-username/zillyzoo.git
   cd zillyzoo
   ```
3. Add the upstream repository:
   ```
   git remote add upstream https://github.com/zillyzoo/zillyzoo.git
   ```
4. Install dependencies:
   ```
   npm install
   ```
   or
   ```
   yarn install
   ```

## Development Workflow

1. Create a new branch from the `develop` branch:
   ```
   git checkout develop
   git pull upstream develop
   git checkout -b feature/your-feature-name
   ```
   
2. Make your changes following the [coding standards](#coding-standards)

3. Run tests to ensure your changes don't break existing functionality:
   ```
   npm test
   ```

4. Commit your changes using [conventional commit messages](https://www.conventionalcommits.org/):
   ```
   git commit -m "feat: add new feature"
   ```

5. Push your branch to your fork:
   ```
   git push origin feature/your-feature-name
   ```

6. Create a pull request to the `develop` branch of the upstream repository

## Pull Request Process

1. Update the README.md or documentation with details of changes if applicable
2. Update the CHANGELOG.md following the [Keep a Changelog](https://keepachangelog.com/) format
3. Make sure all tests pass and linting is successful
4. The PR must be approved by at least one maintainer
5. Once approved, a maintainer will merge your PR

## Coding Standards

- Follow the TypeScript style guide defined in our ESLint and Prettier configurations
- Write clear, commented, and concise code
- Keep functions small and focused on a single responsibility
- Use meaningful variable and function names
- Add appropriate error handling

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types include:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semi-colons, etc)
- `refactor`: Code changes that neither fix a bug nor add a feature
- `perf`: Performance improvements
- `test`: Adding or correcting tests
- `chore`: Changes to the build process, tools, etc.

## Testing Guidelines

- Write unit tests for all new features and bug fixes
- Maintain or improve test coverage
- Write integration tests for complex features
- Follow the existing test patterns in the codebase

## Documentation

- Update documentation when changing functionality
- Document public APIs using JSDoc comments
- Keep README and other documentation up to date
- Create examples for complex features

## Issue Reporting

### Bug Reports

When reporting a bug, please include:
- A clear and descriptive title
- Steps to reproduce the behavior
- Expected behavior
- Actual behavior
- Environment details (OS, browser, etc.)
- Screenshots if applicable

### Feature Requests

For feature requests, please include:
- A clear and descriptive title
- Detailed description of the feature
- Rationale for adding the feature
- Potential implementation details if you have suggestions

## Community

- Join our [Discord server](https://discord.gg/zillyzoo) for real-time discussion
- Subscribe to our [newsletter](https://zillyzoo.com/newsletter) for updates
- Follow us on [Twitter](https://twitter.com/zillyzoo)
- Participate in our [GitHub Discussions](https://github.com/zillyzoo/zillyzoo/discussions)

Thank you for contributing to ZillyOS! 