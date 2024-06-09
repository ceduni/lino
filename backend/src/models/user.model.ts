import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
    timestamp: { type: Date, default: Date.now },
    content: { type: String, required: true },
    read: { type: Boolean, default: false }
});

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // It's gonna be hashed
    email : { type: String, required: true, unique: true },
    phone: {type: String},
    favoriteBooks: [String], // Array of book _ids
    trackedBooks: [mongoose.Schema.Types.ObjectId], // Array of book _ids
    notificationKeyWords: [String],  // Array of key words
    preferredCategories: [String],
    preferredAuthors: [String],
    ecologicalImpact: {
        carbonSavings: { type: Number, default: 0 },
        savedWater: { type: Number, default: 0 },
        savedTrees: { type: Number, default: 0 }
    },
    notifications: {type: [notificationSchema], default: []},
});

const User = mongoose.model('User', userSchema, "users");

export default User;