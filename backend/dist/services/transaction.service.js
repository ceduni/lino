"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const transaction_model_1 = __importDefault(require("../models/transaction.model"));
class TransactionService {
    static createCustomTransaction(params) {
        return __awaiter(this, void 0, void 0, function* () {
            const { username, action, bookTitle, bookboxId, day, hour } = params;
            // Validate day format (AAAA-MM-DD)
            const dayRegex = /^\d{4}-\d{2}-\d{2}$/;
            if (!dayRegex.test(day)) {
                throw new Error('Day must be in format AAAA-MM-DD');
            }
            // Validate hour format (HH:MM)
            const hourRegex = /^\d{2}:\d{2}$/;
            if (!hourRegex.test(hour)) {
                throw new Error('Hour must be in format HH:MM');
            }
            // Build timestamp from day and hour
            const timestampString = `${day}T${hour}:00.000Z`;
            const timestamp = new Date(timestampString);
            // Validate that the constructed date is valid
            if (isNaN(timestamp.getTime())) {
                throw new Error('Invalid date/time combination');
            }
            // Create the transaction
            const transaction = new transaction_model_1.default({
                username,
                action,
                bookTitle,
                bookboxId,
                timestamp
            });
            const savedTransaction = yield transaction.save();
            return savedTransaction;
        });
    }
}
exports.default = TransactionService;
