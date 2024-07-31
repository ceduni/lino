import mongoose from 'mongoose';

const reactSchema = new mongoose.Schema({
    reactIcon : {type: String, required: true}, // The path to the icon of the reaction
    username : {type: String, required: true},
    timestamp: { type: Date, default: Date.now }
});

const messageSchema = new mongoose.Schema({
    username: { type: String, required: true }, // The username of the user who sent the message
    timestamp: { type: Date, default: Date.now },
    content: { type: String, required: true },
    reactions : {type: [reactSchema], default: []}, // Array of reactions
    respondsTo : {type: String, default: ''}, // The id of the message this message is responding to
});

const threadSchema = new mongoose.Schema({
    bookTitle: { type: String, required: true },
    image: { type: String },
    username: { type: String, required: true },
    title: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    messages: { type: [messageSchema], default: [] }
});

// Create a text index on bookTitle, title, and username
threadSchema.index({ bookTitle: 'text', title: 'text', username: 'text' });

const Thread = mongoose.model('Thread', threadSchema, "threads");

export default Thread;