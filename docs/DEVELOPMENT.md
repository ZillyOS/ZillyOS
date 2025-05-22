# ZillyOS Development Guide

This guide will help you set up your local development environment for ZillyOS.

## Prerequisites

Before starting, ensure you have the following installed:

- Node.js (v18 or later)
- npm (v9 or later)
- Git

## Initial Setup

1. **Clone the repository**

```bash
git clone https://github.com/ZillyOS/ZillyOS.git
cd ZillyOS
```

2. **Install dependencies**

```bash
npm install
```

3. **Configure environment variables**

Copy the example environment file and modify as needed:

```bash
cp .env.example .env
```

## Development Workflow

### Starting the Development Server

Run the development server with hot reloading:

```bash
npm run dev
```

This will start the server at http://localhost:3000 (or the port specified in your .env file).

### Running Tests

To run all tests:

```bash
npm test
```

To run tests in watch mode during development:

```bash
npm test -- --watch
```

### Linting and Formatting

To lint your code:

```bash
npm run lint
```

To automatically fix linting issues where possible:

```bash
npm run lint -- --fix
```

To format your code with Prettier:

```bash
npm run prettier
```

### Type Checking

To verify TypeScript types without compiling:

```bash
npm run type-check
```

### Building the Project

To create a production build:

```bash
npm run build
```

The compiled output will be in the `dist` directory.

## Debugging

### Using VS Code

1. Create a `.vscode/launch.json` file with the following configuration:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/src/index.ts",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "runtimeArgs": ["-r", "ts-node/register"],
      "sourceMaps": true,
      "envFile": "${workspaceFolder}/.env"
    }
  ]
}
```

2. Press F5 to start debugging.

### Using Chrome DevTools

1. Start the application with the inspector flag:

```bash
node --inspect-brk -r ts-node/register src/index.ts
```

2. Open Chrome and navigate to `chrome://inspect`
3. Click on the "Open dedicated DevTools for Node" link

## Branch Management

1. Create a feature branch from `develop`:

```bash
git checkout develop
git pull
git checkout -b feature/your-feature-name
```

2. Make your changes, commit them, and push to the remote repository:

```bash
git add .
git commit -m "feat: add new feature"
git push -u origin feature/your-feature-name
```

3. Create a pull request on GitHub to merge your feature branch into `develop`.

## Common Issues and Solutions

### Node Module Resolution Issues

If you're experiencing module resolution issues:

```bash
npm cache clean --force
rm -rf node_modules
npm install
```

### TypeScript Errors

If TypeScript is reporting incorrect errors, try:

```bash
rm -rf dist
npm run type-check
```

## Additional Resources

- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Express.js Documentation](https://expressjs.com/)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started) 