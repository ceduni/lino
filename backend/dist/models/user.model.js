"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const notificationSchema = new mongoose_1.default.Schema({
    timestamp: { type: Date, default: Date.now },
    title: { type: String, required: true },
    content: { type: String, required: true },
    read: { type: Boolean, default: false }
});
const historySchema = new mongoose_1.default.Schema({
    bookId: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    given: { type: Boolean, default: false }
});
const userSchema = new mongoose_1.default.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // It's gonna be hashed
    email: { type: String, required: true, unique: true },
    phone: { type: String },
    notificationKeyWords: [String], // Array of key words
    numSavedBooks: { type: Number, default: 0 },
    notifications: { type: [notificationSchema], default: [] },
    getAlerted: { type: Boolean, default: true },
    bookHistory: { type: [historySchema], default: [] },
});
const User = mongoose_1.default.model('User', userSchema, "users");
exports.default = User;
