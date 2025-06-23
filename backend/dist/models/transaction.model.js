"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const transactionSchema = new mongoose_1.default.Schema({
    username: { type: String, required: true },
    action: { type: String, required: true, enum: ['added', 'took'] },
    bookTitle: { type: String, required: true },
    bookboxName: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
});
const Transaction = mongoose_1.default.model('Transaction', transactionSchema, "transactions");
exports.default = Transaction;
