import mongoose from 'mongoose';

const bookSchema = new mongoose.Schema({
    _id: { type: String, required: true }, // ISBN
    title: { type: String, required: true },
    authors: [String],
    description: String,
    coverImage: String,
    publisher: String,
    categories: [String],
    taken_history: [{ user_id: String, timestamp: { type: Date, default: Date.now } }],
    given_history: [{ user_id: String, timestamp: { type: Date, default: Date.now } }],
    date_last_action: { type: Date, default: Date.now }
});

const Book = mongoose.model('Book', bookSchema, "books"); // "books" specifies the collection to use. If not provided, it will be inferred from the model name

export default Book;