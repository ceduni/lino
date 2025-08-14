"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const notificationSchema = new mongoose_1.default.Schema({
    userId: { type: mongoose_1.default.Schema.Types.ObjectId, ref: 'User', required: true },
    bookId: { type: mongoose_1.default.Schema.Types.ObjectId }, // Optional for book requests
    requestId: { type: mongoose_1.default.Schema.Types.ObjectId, ref: 'Request' }, // Optional for book requests
    bookTitle: { type: String, required: true },
    bookboxId: { type: mongoose_1.default.Schema.Types.ObjectId, ref: 'BookBox' }, // Optional for book requests
    reason: {
        type: [String],
        required: true,
        validate: {
            validator: function (reasons) {
                const validReasons = ['fav_bookbox', 'same_borough', 'fav_genre', 'solved_book_request', 'book_request'];
                return reasons.length > 0 && reasons.every(reason => validReasons.includes(reason));
            },
            message: 'Reason must contain at least one of: fav_bookbox, same_borough, fav_genre, solved_book_request, book_request'
        }
    },
    read: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now }
});
// Add indexes for better query performance
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, read: 1 });
notificationSchema.index({ createdAt: 1 }); // For TTL or cleanup operations
notificationSchema.index({ bookboxId: 1 }); // For bookbox-related queries
notificationSchema.index({ reason: 1 }); // For filtering by notification type
const Notification = mongoose_1.default.model('Notification', notificationSchema, 'notifications');
exports.default = Notification;
