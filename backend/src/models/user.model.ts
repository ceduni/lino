import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // It's gonna be hashed
    favoriteBooks: [String], // Array of ISBNs
    ecologicalImpact: {
        carbonSavings: { type: Number, default: 0 },
        savedWater: { type: Number, default: 0 },
        savedTrees: { type: Number, default: 0 }
    }
});

const User = mongoose.model('User', userSchema, "users");

export default User;