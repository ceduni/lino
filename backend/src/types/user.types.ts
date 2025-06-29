import { Document } from 'mongoose';

// User related types
export interface INotification {
  timestamp: Date;
  title: string;
  content: string;
  read: boolean;
} 

export interface IUser extends Document {
  username: string;
  password: string;
  email: string;
  phone?: string;
  notificationKeyWords: string[];
  requestNotificationRadius: number; // Default radius in km
  numSavedBooks: number;
  notifications: INotification[];
  followedBookboxes: string[];
  createdAt: Date;
}

// User service method types
export interface UserRegistrationData {
  username: string;
  email: string;
  phone?: string;
  password: string;
}

export interface UserLoginCredentials {
  identifier: string;
  password: string;
}

// API Response types
export interface LoginResponse {
  token: string;
}
