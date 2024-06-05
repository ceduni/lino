import mongoose from 'mongoose';

const bookboxSchema = new mongoose.Schema({
    location: [Number],
    infoText: String,
    books: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Book' }], // Array of book _ids
});

const BookBox = mongoose.model('BookBox', bookboxSchema, "bookboxes");

export default BookBox;