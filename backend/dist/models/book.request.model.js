"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const requestSchema = new mongoose_1.default.Schema({
    username: { type: String, required: true },
    bookTitle: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    customMessage: { type: String },
});
const Request = mongoose_1.default.model('Request', requestSchema, "requests");
exports.default = Request;
