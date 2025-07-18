import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({ 
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, 
    email : { type: String, required: true, unique: true },
    phone: { type: String },
    favouriteGenres: { type: [String], default: [] }, // Array of favourite book genres
    favouriteLocations: {
        type: [
            {
                latitude: { type: Number, required: true },
                longitude: { type: Number, required: true },
                name: { type: String, required: true }, // Name of the location
                tag: { type: String }, // Optional tag for the location
                boroughId: { type: String, required: true } // ID of the borough
            }
        ]
    },
    numSavedBooks: { type: Number, default: 0 },
    followedBookboxes: { type: [String], default: [] }, // Array of bookbox IDs
    createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema, "users");

export default User;
