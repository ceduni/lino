import { Document } from 'mongoose';

// Thread related types
export interface IReaction {
  reactIcon: string;
  username: string;
  timestamp: Date;
} 

export interface IMessage {
  username: string;
  timestamp: Date;
  content: string;
  reactions: IReaction[];
  respondsTo: string;
}

export interface IThread extends Document {
  bookTitle: string;
  image?: string;
  username: string;
  title: string;
  timestamp: Date;
  messages: IMessage[];
}

// Thread service method types
export interface ThreadCreateData {
  bookId: string;
  title: string;
  content: string;
}

export interface MessageCreateData {
  content: string;
  threadId: string;
  respondsTo?: string;
}

export interface ReactionData {
  reactIcon: string;
  threadId: string;
  messageId: string;
}

// API Response types
export interface ThreadResponse {
  threadId: string;
}

export interface MessageResponse {
  messageId: string;
}
