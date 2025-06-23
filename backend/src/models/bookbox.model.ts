import mongoose from 'mongoose';

const bookSchema = new mongoose.Schema({
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

const bookboxSchema = new mongoose.Schema({
    name: { type: String, required: true },
    image: String,
    location: [Number],
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

const BookBox = mongoose.model('BookBox', bookboxSchema, "bookboxes");

export default BookBox;
