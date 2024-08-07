import mongoose from 'mongoose';

const bookSchema = new mongoose.Schema({
    isbn: { type: String},
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


const Book = mongoose.model('Book', bookSchema, "books"); // "books" specifies the collection to use

export default Book;