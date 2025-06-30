"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const bookSchema = new mongoose_1.default.Schema({
    isbn: { type: String },
    title: { type: String, required: true },
    authors: [String],
    description: String,
    coverImage: String,
    publisher: String,
    categories: [String],
    parutionYear: Number,
    pages: Number,
    dateAdded: { type: Date, default: Date.now }
});
const bookboxSchema = new mongoose_1.default.Schema({
    name: { type: String, required: true },
    image: String,
    longitude: { type: Number, required: true },
    latitude: { type: Number, required: true },
    infoText: String,
    books: [bookSchema], // Array of nested book documents
});
// Add indexes for efficient searching on nested books
// Text index for full-text search on title, authors, and categories
bookboxSchema.index({
    "books.title": "text",
    "books.authors": "text",
    "books.categories": "text"
});
// Individual indexes for sorting and filtering
bookboxSchema.index({ "books.title": 1 });
bookboxSchema.index({ "books.authors": 1 });
bookboxSchema.index({ "books.parutionYear": 1 });
bookboxSchema.index({ "books.dateAdded": 1 });
bookboxSchema.index({ "books._id": 1 });
const BookBox = mongoose_1.default.model('BookBox', bookboxSchema, "bookboxes");
exports.default = BookBox;
