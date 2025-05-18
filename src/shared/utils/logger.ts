/**
 * ZillyOS - Logger Utility (Placeholder)
 * 
 * A simple logging utility placeholder that will be replaced with a 
 * full-featured logger using winston during Mission 2.
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface LoggerOptions {
  level: LogLevel;
  namespace?: string;
  timestamp?: boolean;
}

/**
 * Creates a simple logger with the specified options
 */
export function createLogger(options: LoggerOptions) {
  const { level, namespace = 'default', timestamp = true } = options;
  
  // Map log levels to their priority numbers (higher = more severe)
  const levels = {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3
  };
  
  const selectedLevelPriority = levels[level];
  
  /**
   * Only logs messages with a level priority greater than or equal to the configured level
   */
  function shouldLog(messageLevel: LogLevel): boolean {
    return levels[messageLevel] >= selectedLevelPriority;
  }
  
  /**
   * Formats a log message with optional timestamp and namespace
   */
  function formatMessage(messageLevel: LogLevel, message: string): string {
    const parts = [];
    
    if (timestamp) {
      parts.push(`[${new Date().toISOString()}]`);
    }
    
    parts.push(`[${namespace}]`);
    parts.push(`[${messageLevel.toUpperCase()}]`);
    parts.push(message);
    
    return parts.join(' ');
  }
  
  return {
    debug: (message: string): void => {
      if (shouldLog('debug')) {
        console.log(formatMessage('debug', message));
      }
    },
    info: (message: string): void => {
      if (shouldLog('info')) {
        console.log(formatMessage('info', message));
      }
    },
    warn: (message: string): void => {
      if (shouldLog('warn')) {
        console.warn(formatMessage('warn', message));
      }
    },
    error: (message: string): void => {
      if (shouldLog('error')) {
        console.error(formatMessage('error', message));
      }
    }
  };
}

// Default logger instance
export const logger = createLogger({ level: 'debug' }); 