"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const bookboxSchema = new mongoose_1.default.Schema({
    name: { type: String, required: true },
    location: [Number],
    infoText: String,
    books: [String], // Array of book _ids
});
const BookBox = mongoose_1.default.model('BookBox', bookboxSchema, "bookboxes");
exports.default = BookBox;
