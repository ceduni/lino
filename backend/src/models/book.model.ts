import mongoose from 'mongoose';

const bookSchema = new mongoose.Schema({
    isbn: { type: String}, // ISBN
    title: { type: String, required: true },
    authors: [String],
    description: String,
    coverImage: String,
    publisher: String,
    categories: [String],
    parutionYear: Number,
    pages: Number,
    taken_history: [{ username: String, timestamp: { type: Date, default: Date.now } }],
    given_history: [{ username: String, timestamp: { type: Date, default: Date.now } }],
    date_last_action: { type: Date, default: Date.now }
});

const Book = mongoose.model('Book', bookSchema, "books"); // "books" specifies the collection to use. If not provided, it will be inferred from the model name

export default Book;