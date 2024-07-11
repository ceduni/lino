import mongoose from 'mongoose';

const bookboxSchema = new mongoose.Schema({
    name: { type: String, required: true },
    location: [Number],
    infoText: String,
    books: [String], // Array of book _ids
});

// Create a text index on name and infoText
bookboxSchema.index({ name: 'text', infoText: 'text' });

const BookBox = mongoose.model('BookBox', bookboxSchema, "bookboxes");

export default BookBox;