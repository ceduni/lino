import { FastifyRequest } from 'fastify';

// Common API types
export interface ApiError {
  error: string;
} 

// Fastify request extensions
export interface AuthenticatedRequest extends FastifyRequest {
  user: {
    id: string;
    username: string;
  };
  jwtVerify(): Promise<any>;
}

// Extended FastifyRequest with JWT methods
export interface FastifyRequestWithJWT extends FastifyRequest {
  jwtVerify(): Promise<any>;
  user?: any;
}

// WebSocket client type
export interface WebSocketClient extends WebSocket {
  userId?: string;
  on(event: 'message', listener: (data: Buffer) => void): this;
  on(event: 'close', listener: () => void): this;
  on(event: string, listener: (...args: any[]) => void): this;
}
