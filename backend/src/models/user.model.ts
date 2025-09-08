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
    notificationSettings: {
        type: {
            addedBook: { type: Boolean, default: true },
            bookRequested: { type: Boolean, default: true },
        },
        default: {
            addedBook: true,
            bookRequested: true
        }
    },
    profilePictureUrl: { type: String, default: "" },
    numIssuesReported: { type: Number, default: 0 },
    numSavedBooks: { type: Number, default: 0 },
    followedBookboxes: { type: [String], default: [] }, // Array of bookbox IDs
    createdAt: { type: Date, default: Date.now },
    isAdmin: { type: Boolean, default: false },
});

const User = mongoose.model('User', userSchema, "users");

export default User;
