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
const _1 = require(".");
const utilities_1 = require("../utilities/utilities");
const bookboxService = {
    getBookBox(bookBoxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBox = yield models_1.BookBox.findById(bookBoxId);
            if (!bookBox) {
                throw new Error('Bookbox not found');
            }
            return bookBox;
        });
    },
    // Add a book to a bookbox as a nested document
    addBook(_a) {
        return __awaiter(this, arguments, void 0, function* ({ bookboxId, title, isbn, authors, description, coverImage, publisher, parutionYear, pages, categories, userId }) {
            var _b, _c;
            if (!title) {
                throw (0, utilities_1.newErr)(400, 'Book title is required');
            }
            let bookBox = yield models_1.BookBox.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            if (!bookBox.isActive) {
                throw (0, utilities_1.newErr)(400, 'This bookbox is not active');
            }
            // Create new book object
            const newBook = {
                isbn: isbn,
                title: title,
                authors: authors || [],
                description: description || "No description available",
                coverImage: coverImage || "No cover image",
                publisher: publisher || "Unknown Publisher",
                parutionYear: parutionYear || undefined,
                pages: pages || undefined,
                categories: categories || [],
                dateAdded: new Date()
            };
            // Add book to bookbox
            bookBox.books.push(newBook);
            yield bookBox.save();
            // Get the added book with its generated ID
            const addedBook = bookBox.books[bookBox.books.length - 1];
            // Create transaction record
            const username = userId ? ((_b = (yield models_1.User.findById(userId))) === null || _b === void 0 ? void 0 : _b.username) || 'guest' : 'guest';
            yield _1.TransactionService.createTransaction(username, 'added', title, bookboxId);
            // Notify users about the new book
            yield _1.NotificationService.notifyRelevantUsers(username, newBook, bookBox._id.toString());
            // Increment user's added books count
            if (userId) {
                const user = yield models_1.User.findById(userId);
                if (user) {
                    // Ensure the user has followed the bookbox
                    if (!user.followedBookboxes.includes(bookBox._id.toString())) {
                        user.followedBookboxes.push(bookBox._id.toString());
                    }
                    user.numSavedBooks++;
                    yield user.save();
                }
            }
            return { bookId: (_c = addedBook._id) === null || _c === void 0 ? void 0 : _c.toString(), books: bookBox.books };
        });
    },
    getBookFromBookBox(bookboxId, bookId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            // Find the bookbox
            let bookBox = yield models_1.BookBox.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            if (!bookBox.isActive) {
                throw (0, utilities_1.newErr)(400, 'This bookbox is not active');
            }
            // Find the book in the bookbox
            const bookIndex = bookBox.books.findIndex(book => { var _a; return ((_a = book._id) === null || _a === void 0 ? void 0 : _a.toString()) === bookId; });
            if (bookIndex === -1) {
                throw (0, utilities_1.newErr)(404, 'Book not found in bookbox');
            }
            const book = bookBox.books[bookIndex];
            // Remove the book from the bookbox
            bookBox.books.splice(bookIndex, 1);
            yield bookBox.save();
            // Create transaction record
            const username = userId ? ((_a = (yield models_1.User.findById(userId))) === null || _a === void 0 ? void 0 : _a.username) || 'guest' : 'guest';
            yield _1.TransactionService.createTransaction(username, 'took', book.title, bookboxId);
            // Increment user's saved books count
            if (userId) {
                const user = yield models_1.User.findById(userId);
                if (user) {
                    // If the user doesn't follow this bookbox, add it to their followed bookboxes
                    if (!user.followedBookboxes.includes(bookBox._id.toString())) {
                        user.followedBookboxes.push(bookBox._id.toString());
                    }
                    user.numSavedBooks++;
                    yield user.save();
                }
            }
            return { book: book, books: bookBox.books };
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield models_1.BookBox.deleteMany({});
        });
    },
    followBookBox(id, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (!user.followedBookboxes.includes(bookboxId)) {
                user.followedBookboxes.push(bookboxId);
                yield user.save();
            }
            return { message: 'Bookbox followed successfully' };
        });
    },
    unfollowBookBox(id, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            user.followedBookboxes = user.followedBookboxes.filter(id => id !== bookboxId);
            yield user.save();
            return { message: 'Bookbox unfollowed successfully' };
        });
    },
};
exports.default = bookboxService;
