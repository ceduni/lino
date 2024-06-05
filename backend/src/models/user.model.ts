import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // It's gonna be hashed
    email : { type: String, required: true, unique: true },
    phone: {type: String},
    favoriteBooks: [String], // Array of ISBNs
    trackedBooks: [mongoose.Schema.Types.ObjectId], // Array of book _ids
    preferredCategories: [String],
    preferredAuthors: [String],
    ecologicalImpact: {
        carbonSavings: { type: Number, default: 0 },
        savedWater: { type: Number, default: 0 },
        savedTrees: { type: Number, default: 0 }
    }
});

const User = mongoose.model('User', userSchema, "users");

export default User;