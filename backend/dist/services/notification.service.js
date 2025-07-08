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
const notification_model_1 = __importDefault(require("../models/notification.model"));
const user_model_1 = __importDefault(require("../models/user.model"));
const bookbox_model_1 = __importDefault(require("../models/bookbox.model"));
const utilities_1 = require("./utilities");
const index_1 = require("../index");
const NotificationService = {
    // Create a new notification
    createNotification(userId_1, reasons_1) {
        return __awaiter(this, arguments, void 0, function* (userId, reasons, options = {}) {
            const notification = new notification_model_1.default({
                userId,
                bookId: options.bookId,
                bookTitle: options.bookTitle,
                bookboxId: options.bookboxId,
                reason: reasons,
                read: false
            });
            yield notification.save();
            // Broadcast the notification to the user if they are connected via WebSocket
            (0, index_1.broadcastToUser)(userId, {
                event: 'newNotification',
                data: {
                    _id: notification._id,
                    userId: notification.userId,
                    bookId: notification.bookId,
                    bookTitle: notification.bookTitle,
                    bookboxId: notification.bookboxId,
                    reason: notification.reason,
                    read: notification.read,
                    createdAt: notification.createdAt
                }
            });
            return notification;
        });
    },
    // Get user notifications (last 30 days)
    getUserNotifications(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const userId = request.user.id;
            // Calculate the date 30 days ago
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
            const notifications = yield notification_model_1.default.find({
                userId: userId,
                createdAt: { $gte: thirtyDaysAgo }
            }).sort({ createdAt: -1 });
            return notifications;
        });
    },
    // Mark a notification as read
    readNotification(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const userId = request.user.id;
            const notificationId = request.body.notificationId;
            const notification = yield notification_model_1.default.findOne({
                _id: notificationId,
                userId: userId
            });
            if (!notification) {
                throw (0, utilities_1.newErr)(404, 'Notification not found');
            }
            notification.read = true;
            yield notification.save();
            // Return all user notifications after marking as read
            return yield this.getUserNotifications(request);
        });
    },
    // Notify relevant users when a book is added to a bookbox
    notifyRelevantUsers(username, book, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const bookBox = yield bookbox_model_1.default.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            const users = yield user_model_1.default.find();
            for (const user of users) {
                if (user.username === username) {
                    continue; // Skip the user who added the book
                }
                const reasons = [];
                // Check if user follows this bookbox
                if (user.followedBookboxes.includes(bookboxId)) {
                    reasons.push('fav_bookbox');
                }
                // Check if user is in the same borough
                if (user.boroughId && user.boroughId === bookBox.boroughId) {
                    reasons.push('same_borough');
                }
                // Check if book categories match user's favourite genres
                if (user.favouriteGenres && user.favouriteGenres.length > 0 && book.categories) {
                    const hasMatchingGenre = book.categories.some(category => user.favouriteGenres.some(genre => genre.toLowerCase() === category.toLowerCase()));
                    if (hasMatchingGenre) {
                        reasons.push('fav_genre');
                    }
                }
                // Create notification if at least one reason exists
                if (reasons.length > 0) {
                    yield this.createNotification(user._id.toString(), reasons, {
                        bookId: ((_a = book._id) === null || _a === void 0 ? void 0 : _a.toString()) || '',
                        bookboxId: bookboxId
                    });
                }
            }
        });
    },
    // Clear all notifications (for testing/admin purposes)
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield notification_model_1.default.deleteMany({});
        });
    }
};
exports.default = NotificationService;
