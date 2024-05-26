import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema({
    user_id: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    content: { type: String, required: true }
});

const threadSchema = new mongoose.Schema({
    book_id: { type: String, required: true },
    user_id: { type: String, required: true },
    title: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    messages: { type: [messageSchema], default: [] }
});

const Thread = mongoose.model('Thread', threadSchema, "threads");

export default Thread;