import mongoose from 'mongoose';

const bookSchema = new mongoose.Schema({
    isbn: { type: String, required: true }, // ISBN
    title: { type: String, required: true },
    authors: [String],
    description: String,
    coverImage: String,
    publisher: String,
    categories: [String],
    // 5: new, 4: like new, 3: very good, 2: good, 1: acceptable, 0: poor
    physical_state: {type: Number, enum: [0,1,2,3,4,5], default: 5},
    taken_history: [{ user_id: String, timestamp: { type: Date, default: Date.now } }],
    given_history: [{ user_id: String, timestamp: { type: Date, default: Date.now } }],
    date_last_action: { type: Date, default: Date.now }
});

const Book = mongoose.model('Book', bookSchema, "books"); // "books" specifies the collection to use. If not provided, it will be inferred from the model name

export default Book;