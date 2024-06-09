import mongoose from 'mongoose';

const bookboxSchema = new mongoose.Schema({
    name: { type: String, required: true },
    location: [Number],
    infoText: String,
    books: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Book' }], // Array of book _ids
});

const BookBox = mongoose.model('BookBox', bookboxSchema, "bookboxes");

export default BookBox;