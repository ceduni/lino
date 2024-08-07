import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
    timestamp: { type: Date, default: Date.now },
    title: { type: String, required: true },
    content: { type: String, required: true },
    read: { type: Boolean, default: false }
});


const historySchema = new mongoose.Schema({
    bookId: {type: String, required: true},
    timestamp: {type: Date, default: Date.now},
    given: {type: Boolean, default: false}
});

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // It's gonna be hashed
    email : { type: String, required: true, unique: true },
    phone: {type: String},
    favoriteBooks: [String], // Array of book _ids
    trackedBooks: [String], // Array of book _ids, inaccessible for the user, only for the system
    notificationKeyWords: [String],  // Array of key words
    ecologicalImpact: {
        carbonSavings: { type: Number, default: 0 }, // 27.71 kg CO2 per saved book
        savedWater: { type: Number, default: 0 }, // 2000 liters per saved book
        savedTrees: { type: Number, default: 0 } // 0.005 trees per saved book
    },
    notifications: {type: [notificationSchema], default: []},
    getAlerted: { type: Boolean, default: true },
    bookHistory: {type: [historySchema], default: []},
});

const User = mongoose.model('User', userSchema, "users");

export default User;