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
Object.defineProperty(exports, "__esModule", { value: true });
const models_1 = require("../models");
class TransactionService {
    // Create a transaction record
    static createTransaction(username, action, bookTitle, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const transaction = new models_1.Transaction({
                username,
                action,
                bookTitle,
                bookboxId
            });
            yield transaction.save();
            return transaction;
        });
    }
    static createCustomTransaction(username, action, bookTitle, bookboxId, day, // Format: AAAA-MM-DD
    hour // Format: HH:MM
    ) {
        return __awaiter(this, void 0, void 0, function* () {
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
            const transaction = new models_1.Transaction({
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
    static clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield models_1.Transaction.deleteMany({});
            return { message: 'Transactions cleared' };
        });
    }
}
exports.default = TransactionService;
