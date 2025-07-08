"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const userSchema = new mongoose_1.default.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String },
    requestNotificationRadius: { type: Number, default: 5 }, // Default radius in km
    favouriteGenres: { type: [String], default: [] }, // Array of favourite book genres
    boroughId: { type: String }, // Borough ID for location-based notifications
    numSavedBooks: { type: Number, default: 0 },
    followedBookboxes: { type: [String], default: [] }, // Array of bookbox IDs
    createdAt: { type: Date, default: Date.now },
});
const User = mongoose_1.default.model('User', userSchema, "users");
exports.default = User;
