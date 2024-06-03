import mongoose from 'mongoose';

const bookboxSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    name: String,
    location: {
        type: { type: String },
        coordinates: [Number]
    },
    infoText: String,
    books: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Book' }], // Array of book _ids
});

const BookBox = mongoose.model('BookBox', bookboxSchema, "bookboxes");

export default BookBox;