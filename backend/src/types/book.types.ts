import { Document } from 'mongoose';

// Book related types (now as nested documents)
export interface IBook {
  _id?: string;
  isbn?: string;
  title: string;
  authors: string[];
  description?: string;
  coverImage?: string;
  publisher?: string;
  categories: string[];
  parutionYear?: number;
  pages?: number;
  dateAdded: Date;
}

// BookBox related types
export interface IBookBox extends Document {
  name: string;
  image?: string;
  location: number[];
  infoText?: string;
  books: IBook[];
}

// Transaction related types
export interface ITransaction extends Document {
  username: string;
  action: 'added' | 'took';
  bookTitle: string;
  bookboxName: string;
  timestamp: Date;
}

// Request related types
export interface IRequest extends Document {
  username: string;
  bookTitle: string;
  timestamp: Date;
  customMessage?: string;
}

// Book service method types
export interface BookAddData {
  isbn?: string;
  title: string;
  authors?: string[];
  description?: string;
  coverImage?: string;
  publisher?: string;
  parutionYear?: number;
  pages?: number;
  categories?: string[];
}

export interface BookSearchQuery {
  kw?: string;
  cls?: string;
  asc?: boolean;
}

// API Response types
export interface BookAddResponse {
  bookId: string;
  books: string[];
}

export interface BookSearchResponse {
  books: IBook[];
}
