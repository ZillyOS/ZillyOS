# ZillyOS Release Process

This document outlines the release process for ZillyOS, including version numbering, branch management, and deployment steps.

## Version Numbering

ZillyOS follows [Semantic Versioning](https://semver.org/) (SemVer):

- **Major version** (X.0.0): Incompatible API changes
- **Minor version** (0.X.0): New functionality in a backward-compatible manner
- **Patch version** (0.0.X): Backward-compatible bug fixes

### Pre-release Versions

Pre-release versions use the following format:

- **Alpha**: `0.1.0-alpha.1`
- **Beta**: `0.1.0-beta.1`
- **Release Candidate**: `0.1.0-rc.1`

## Release Cycle

ZillyOS follows a regular release cycle:

1. **Development Phase**: New features are developed in feature branches
2. **Feature Freeze**: No new features are added, only bug fixes
3. **Release Candidate**: Final testing before release
4. **Release**: Stable version is released
5. **Maintenance**: Bug fixes and security patches

## Branch Strategy

The branching strategy for releases is as follows:

- **main**: Contains the latest stable release
- **develop**: Development branch for the next release
- **staging**: Pre-release testing branch
- **feature/***:  Feature development branches
- **release/X.Y.Z**: Release preparation branches
- **hotfix/***:  Hotfix branches for critical issues

## Release Preparation

### 1. Create Release Branch

```bash
git checkout develop
git pull
git checkout -b release/X.Y.Z
```

### 2. Update Version Numbers

- Update `package.json` version
- Update `version.txt`
- Update any other version references

### 3. Update Changelog

- Move items from "Unreleased" to the new version section
- Add release date
- Add a new empty "Unreleased" section

### 4. Create Release Candidate

If needed, create a release candidate:

```bash
# Update version in package.json to X.Y.Z-rc.1
npm version prerelease --preid rc
```

### 5. Final Testing

- Deploy to staging environment
- Perform regression testing
- Verify documentation

## Release Execution

### 1. Merge Release Branch to Main

```bash
git checkout main
git pull
git merge --no-ff release/X.Y.Z
git tag -a vX.Y.Z -m "Version X.Y.Z"
git push origin main --tags
```

### 2. Merge Back to Develop

```bash
git checkout develop
git pull
git merge --no-ff release/X.Y.Z
git push origin develop
```

### 3. Create GitHub Release

- Go to GitHub Releases
- Draft a new release
- Select the tag
- Add release notes from the changelog
- Publish the release

### 4. Publish to npm

```bash
npm publish
```

## Hotfix Process

For critical issues that need immediate fixes:

### 1. Create Hotfix Branch

```bash
git checkout main
git pull
git checkout -b hotfix/X.Y.Z+1
```

### 2. Implement Fix

- Make minimal changes to fix the issue
- Add tests
- Update changelog
- Bump patch version

### 3. Merge to Main and Develop

```bash
# Merge to main
git checkout main
git pull
git merge --no-ff hotfix/X.Y.Z+1
git tag -a vX.Y.Z+1 -m "Version X.Y.Z+1"
git push origin main --tags

# Merge to develop
git checkout develop
git pull
git merge --no-ff hotfix/X.Y.Z+1
git push origin develop
```

## Post-Release Tasks

1. **Announcement**: Announce the release on:
   - GitHub Discussions
   - Discord community
   - Twitter/X
   - Blog post

2. **Documentation**: Ensure documentation is updated for the new version

3. **Feedback**: Monitor for issues and gather feedback

4. **Planning**: Begin planning for the next release

## Release Checklist

- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Changelog is updated
- [ ] Version numbers are updated
- [ ] Release branch is created
- [ ] Final testing completed
- [ ] Release branch merged to main
- [ ] Tags created and pushed
- [ ] GitHub release created
- [ ] Package published to npm
- [ ] Release announcement sent
- [ ] Post-release monitoring in place 