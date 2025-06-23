"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const reactSchema = new mongoose_1.default.Schema({
    reactIcon: { type: String, required: true }, // The path to the icon of the reaction
    username: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
});
const messageSchema = new mongoose_1.default.Schema({
    username: { type: String, required: true }, // The username of the user who sent the message
    timestamp: { type: Date, default: Date.now },
    content: { type: String, required: true },
    reactions: { type: [reactSchema], default: [] }, // Array of reactions
    respondsTo: { type: String, default: '' }, // The id of the message this message is responding to
});
const threadSchema = new mongoose_1.default.Schema({
    bookTitle: { type: String, required: true },
    image: { type: String },
    username: { type: String, required: true },
    title: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    messages: { type: [messageSchema], default: [] }
});
const Thread = mongoose_1.default.model('Thread', threadSchema, "threads");
exports.default = Thread;
