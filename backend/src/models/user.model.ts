import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
    timestamp: { type: Date, default: Date.now },
    title: { type: String, required: true },
    content: { type: String, required: true },
    read: { type: Boolean, default: false }
});

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, 
    email : { type: String, required: true, unique: true },
    phone: {type: String},
    requestNotificationRadius: { type: Number, default: 5 }, // Default radius in km
    notificationKeyWords: [String],  // Array of key words
    numSavedBooks: { type: Number, default: 0 },
    notifications: {type: [notificationSchema], default: []},
    followedBookboxes: { type: [String], default: [] }, // Array of bookbox IDs
    createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema, "users");

export default User;