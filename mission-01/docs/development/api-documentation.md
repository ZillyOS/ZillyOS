# API Documentation Style Guide

This guide outlines the standards for documenting APIs in the ZillyOS project. Following these standards ensures that our API documentation is consistent, clear, and helpful to users.

## TypeScript Documentation

All TypeScript code should be documented using JSDoc comments with TypeScript type annotations.

### Classes

Document classes with a description, any type parameters, and relevant tags.

```typescript
/**
 * Represents a ZillyOS application instance.
 * 
 * @typeParam T - The type of configuration object
 */
class Application<T extends Config> {
  // Class implementation
}
```

### Methods

Document methods with a description, parameters, return type, and any exceptions.

```typescript
/**
 * Starts the application with the provided options.
 * 
 * @param options - Configuration options for starting the application
 * @returns A promise that resolves when the application has started
 * @throws {ConfigError} If the configuration is invalid
 * @example
 * ```typescript
 * const app = new Application();
 * await app.start({ port: 3000 });
 * ```
 */
async start(options: StartOptions): Promise<void> {
  // Method implementation
}
```

### Properties

Document class properties with their purpose and any constraints.

```typescript
/**
 * The unique identifier for this application instance.
 * This ID is generated when the application is created and cannot be changed.
 */
readonly id: string;
```

### Interfaces

Document interfaces with a description and each property.

```typescript
/**
 * Configuration options for the application.
 */
interface Config {
  /**
   * The name of the application.
   */
  name: string;
  
  /**
   * The port on which the application will listen.
   * Must be between 1 and 65535.
   */
  port: number;
  
  /**
   * Optional logger instance.
   * If not provided, a default logger will be used.
   */
  logger?: Logger;
}
```

## REST API Documentation

REST APIs should be documented using the standard template in the API documentation.

### Endpoint Documentation

Each endpoint should include:

1. HTTP method and path
2. Description of what the endpoint does
3. Request parameters (path, query, body)
4. Response format for success and error cases
5. Example requests and responses
6. Authentication requirements
7. Rate limiting information if applicable

Example:

```markdown
## Get User

Retrieves a user by their ID.

### Request

`GET /api/users/{id}`

### Path Parameters

| Name | Type | Description | Required |
|------|------|-------------|----------|
| id   | string | The user's unique identifier | Yes |

### Query Parameters

| Name | Type | Description | Required | Default |
|------|------|-------------|----------|---------|
| fields | string | Comma-separated list of fields to include | No | All fields |

### Response

#### 200 OK

```json
{
  "id": "usr_123",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2023-01-15T12:00:00Z"
}
```

#### 404 Not Found

```json
{
  "error": "User not found",
  "code": "USER_NOT_FOUND",
  "requestId": "req_abc123"
}
```

### Example

```bash
curl -X GET https://api.example.com/api/users/usr_123 \
  -H "Authorization: Bearer {token}"
```
```

## Code Examples

Include code examples for common use cases. Code examples should:

1. Be concise and focused on the specific functionality
2. Include imports and any necessary setup
3. Use proper syntax highlighting
4. Follow project coding standards
5. Be tested to ensure they work as documented

```typescript
// Example of using the EventEmitter
import { EventEmitter } from 'zillys';

// Create a new event emitter
const emitter = new EventEmitter();

// Register an event handler
emitter.on('message', (data) => {
  console.log(`Received message: ${data.text}`);
});

// Emit an event
emitter.emit('message', { text: 'Hello, world!' });
```

## Versioning Information

Always include version information for APIs:

1. When the API was introduced
2. Any changes in behavior across versions
3. Deprecation notices with migration paths

Example:

```markdown
> **Available since:** v1.2.0  
> **Deprecated in:** v2.0.0 (use `newMethod()` instead)  
> **Removed in:** v3.0.0
```

## Error Documentation

Document all possible errors that can be returned by an API:

1. Error codes
2. HTTP status codes (for REST APIs)
3. Error messages
4. Possible causes
5. Recommended actions

Example:

```markdown
## Error Codes

| Code | HTTP Status | Description | Resolution |
|------|-------------|-------------|------------|
| AUTH_REQUIRED | 401 | Authentication required | Provide a valid authentication token |
| INVALID_INPUT | 400 | Invalid input provided | Check the request parameters against the API documentation |
| RATE_LIMITED | 429 | Too many requests | Reduce request frequency or contact support for rate limit increase |
```

## API Stability

Use labels to indicate the stability of each API:

1. **Stable**: API is fully supported and will not change without notice
2. **Beta**: API is mostly stable but may have breaking changes in future versions
3. **Experimental**: API is under development and may change significantly
4. **Deprecated**: API will be removed in a future version

Example:

```markdown
> **Stability:** Beta  
> This API is in beta and may have breaking changes in future versions.
```

## Updating Documentation

API documentation should be updated:

1. When new APIs are added
2. When existing APIs are modified
3. When APIs are deprecated or removed
4. When new examples or use cases should be highlighted

Changes to the API documentation should go through the same review process as code changes. 