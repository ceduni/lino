import { Document } from 'mongoose';

// Notification related types (for the new separate collection)
export interface INotification extends Document {
  userId: string;
  bookId?: string;
  bookTitle?: string;
  bookboxId?: string;
  reason: string[];
  read: boolean;
  createdAt: Date;
}

export interface IUser extends Document {
  username: string;
  password: string;
  email: string;
  phone?: string;
  favouriteGenres: string[];
  boroughId?: string;
  requestNotificationRadius: number; // Default radius in km
  numSavedBooks: number;
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
