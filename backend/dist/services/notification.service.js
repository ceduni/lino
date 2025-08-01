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
const utilities_1 = require("../utilities/utilities");
const index_1 = require("../index");
const _1 = require(".");
const NotificationService = {
    // Create a new notification
    createNotification(userId_1, reasons_1, bookTitle_1) {
        return __awaiter(this, arguments, void 0, function* (userId, reasons, bookTitle, options = {}) {
            const notification = new models_1.Notification({
                userId,
                bookId: options.bookId,
                bookTitle: bookTitle,
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
    getUserNotifications(id) {
        return __awaiter(this, void 0, void 0, function* () {
            const userId = id;
            // Calculate the date 30 days ago
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
            const notifications = yield models_1.Notification.find({
                userId: userId,
                createdAt: { $gte: thirtyDaysAgo }
            }).sort({ createdAt: -1 });
            return notifications;
        });
    },
    // Mark a notification as read
    readNotification(id, notificationId) {
        return __awaiter(this, void 0, void 0, function* () {
            const userId = id;
            const notification = yield models_1.Notification.findOne({
                _id: notificationId,
                userId: userId
            });
            if (!notification) {
                throw (0, utilities_1.newErr)(404, 'Notification not found');
            }
            notification.read = true;
            yield notification.save();
            // Return all user notifications after marking as read
            return yield this.getUserNotifications(userId);
        });
    },
    // Notify relevant users when a book is added to a bookbox
    notifyRelevantUsers(username, book, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBox = yield models_1.BookBox.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            const users = yield models_1.User.find();
            for (const user of users) {
                if (user.username === username || !user.notificationSettings.addedBook) {
                    continue; // Skip the user who added the book or if they don't accept this notification type
                }
                const reasons = [];
                // Check if user follows this bookbox
                if (user.followedBookboxes.includes(bookboxId)) {
                    reasons.push('fav_bookbox');
                }
                // Check if the borough matches one of the user's favourite locations
                for (const location of user.favouriteLocations) {
                    if (location.boroughId === bookBox.boroughId) {
                        reasons.push('same_borough');
                        break; // Exit early since we only need to find one match
                    }
                }
                // Create notification if there's at least a reason related to the book box
                if (reasons.length > 0) {
                    // Check if book categories match user's favourite genres
                    if (user.favouriteGenres && user.favouriteGenres.length > 0 && book.categories) {
                        const hasMatchingGenre = book.categories.some(category => user.favouriteGenres.some(genre => genre.toLowerCase() === category.toLowerCase()));
                        if (hasMatchingGenre) {
                            reasons.push('fav_genre');
                        }
                    }
                    const requests = yield _1.RequestService.getBookRequests(user.username);
                    // Check if the book matches the user's request
                    if (requests.some(req => req.bookTitle.toLowerCase() === book.title.toLowerCase())) {
                        reasons.push('solved_book_request');
                    }
                    const notificationOptions = {
                        bookboxId: bookboxId
                    };
                    // Only include bookId if it exists and is not empty
                    if (book._id && book._id.toString()) {
                        notificationOptions.bookId = book._id.toString();
                    }
                    yield this.createNotification(user._id.toString(), reasons, book.title, notificationOptions);
                }
            }
        });
    },
    // Clear all notifications (for testing/admin purposes)
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield models_1.Notification.deleteMany({});
        });
    }
};
exports.default = NotificationService;
