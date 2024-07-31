"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const bookSchema = new mongoose_1.default.Schema({
    isbn: { type: String },
    qrCodeId: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    authors: [String],
    description: String,
    coverImage: String,
    publisher: String,
    categories: [String],
    parutionYear: Number,
    pages: Number,
    takenHistory: [{ username: String, timestamp: { type: Date, default: Date.now } }],
    givenHistory: [{ username: String, timestamp: { type: Date, default: Date.now } }],
    dateLastAction: { type: Date, default: Date.now }
});
// Create a text index on title, authors
bookSchema.index({ title: 'text', authors: 'text' });
const Book = mongoose_1.default.model('Book', bookSchema, "books"); // "books" specifies the collection to use
exports.default = Book;
