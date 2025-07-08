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
const axios_1 = __importDefault(require("axios"));
const mongoose_1 = __importDefault(require("mongoose"));
const bookbox_model_1 = __importDefault(require("../models/bookbox.model"));
const user_model_1 = __importDefault(require("../models/user.model"));
const book_request_model_1 = __importDefault(require("../models/book.request.model"));
const transaction_model_1 = __importDefault(require("../models/transaction.model"));
const notification_service_1 = __importDefault(require("./notification.service"));
const utilities_1 = require("./utilities");
const bookService = {
    getBookInfoFromISBN(request) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const isbn = request.params.isbn;
            const response = yield axios_1.default.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}&key=${process.env.GOOGLE_BOOKS_API_KEY}`);
            if (response.data.totalItems === 0) {
                throw (0, utilities_1.newErr)(404, 'Book not found');
            }
            const bookInfo = response.data.items[0].volumeInfo;
            const parutionYear = bookInfo.publishedDate ? parseInt(bookInfo.publishedDate.substring(0, 4)) : undefined;
            const pageCount = bookInfo.pageCount ? parseInt(bookInfo.pageCount) : undefined;
            return {
                isbn: isbn,
                title: bookInfo.title || 'Unknown title',
                authors: bookInfo.authors || ['Unknown author'],
                description: bookInfo.description || 'No description available',
                coverImage: ((_a = bookInfo.imageLinks) === null || _a === void 0 ? void 0 : _a.thumbnail) || 'No thumbnail available',
                publisher: bookInfo.publisher || 'Unknown publisher',
                parutionYear: parutionYear,
                categories: bookInfo.categories || ['Uncategorized'],
                pages: pageCount,
            };
        });
    },
    // Function that searches for books across all bookboxes based on keyword search and ordering filters
    // Optimized using MongoDB aggregation pipeline for better performance
    searchBooks(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { kw, cls = 'by title', asc = true } = request.query;
            // Build aggregation pipeline
            const pipeline = [
                // Unwind the books array to work with individual books
                { $unwind: '$books' },
                // Add bookbox information to each book
                {
                    $addFields: {
                        'books.bookboxId': { $toString: '$_id' },
                        'books.bookboxName': '$name'
                    }
                }
            ];
            // Add keyword filtering stage if keyword is provided
            if (kw) {
                // Use text search if available, otherwise use regex
                pipeline.push({
                    $match: {
                        $or: [
                            { 'books.title': { $regex: kw, $options: 'i' } },
                            { 'books.authors': { $regex: kw, $options: 'i' } },
                            { 'books.categories': { $regex: kw, $options: 'i' } }
                        ]
                    }
                });
            }
            // Add sorting stage
            let sortField;
            let sortOrder = asc ? 1 : -1;
            switch (cls) {
                case 'by title':
                    sortField = 'books.title';
                    break;
                case 'by author':
                    sortField = 'books.authors';
                    break;
                case 'by year':
                    sortField = 'books.parutionYear';
                    break;
                case 'by recent activity':
                    sortField = 'books.dateAdded';
                    break;
                default:
                    sortField = 'books.title';
            }
            pipeline.push({ $sort: { [sortField]: sortOrder } });
            // Project the final structure
            pipeline.push({
                $project: {
                    _id: { $toString: '$books._id' },
                    isbn: { $ifNull: ['$books.isbn', 'Unknown ISBN'] },
                    title: '$books.title',
                    authors: { $ifNull: ['$books.authors', []] },
                    description: { $ifNull: ['$books.description', 'No description available'] },
                    coverImage: { $ifNull: ['$books.coverImage', 'No cover image available'] },
                    publisher: { $ifNull: ['$books.publisher', 'Unknown publisher'] },
                    categories: { $ifNull: ['$books.categories', ['Uncategorized']] },
                    parutionYear: '$books.parutionYear',
                    pages: '$books.pages',
                    dateAdded: { $ifNull: ['$books.dateAdded', new Date()] },
                    bookboxId: '$books.bookboxId',
                    bookboxName: '$books.bookboxName'
                }
            });
            // Execute the aggregation pipeline
            const results = yield bookbox_model_1.default.aggregate(pipeline);
            return results;
        });
    },
    getBook(id) {
        return __awaiter(this, void 0, void 0, function* () {
            // Use aggregation pipeline to efficiently find book by ID
            const pipeline = [
                // Unwind the books array
                { $unwind: '$books' },
                // Match the specific book ID
                { $match: { 'books._id': new mongoose_1.default.Types.ObjectId(id) } },
                // Project the result with bookbox information
                {
                    $project: {
                        _id: { $toString: '$books._id' },
                        isbn: { $ifNull: ['$books.isbn', 'Unknown ISBN'] },
                        title: '$books.title',
                        authors: { $ifNull: ['$books.authors', []] },
                        description: { $ifNull: ['$books.description', 'No description available'] },
                        coverImage: { $ifNull: ['$books.coverImage', 'No cover image available'] },
                        publisher: { $ifNull: ['$books.publisher', 'Unknown publisher'] },
                        categories: { $ifNull: ['$books.categories', ['Uncategorized']] },
                        parutionYear: '$books.parutionYear',
                        pages: '$books.pages',
                        dateAdded: { $ifNull: ['$books.dateAdded', new Date()] },
                        bookboxId: { $toString: '$_id' },
                        bookboxName: '$name'
                    }
                },
                // Limit to 1 result since we're looking for a specific book
                { $limit: 1 }
            ];
            const results = yield bookbox_model_1.default.aggregate(pipeline);
            return results.length > 0 ? results[0] : null;
        });
    },
    requestBookToUsers(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(request.user.id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const { latitude, longitude } = request.query;
            if (!latitude || !longitude) {
                throw (0, utilities_1.newErr)(400, 'User location (latitude and longitude) is required');
            }
            // Get all bookboxes and filter by distance using Haversine formula
            const allBookboxes = yield bookbox_model_1.default.find();
            const nearbyBookboxes = allBookboxes.filter(bookbox => {
                if (!bookbox.longitude || !bookbox.latitude) {
                    return false;
                }
                const distance = this.calculateDistance(latitude, longitude, bookbox.latitude, bookbox.longitude);
                return distance <= user.requestNotificationRadius;
            });
            // Get all unique users who follow any of these nearby bookboxes
            const bookboxIds = nearbyBookboxes.map(bookbox => bookbox._id.toString());
            const usersToNotify = yield user_model_1.default.find({
                followedBookboxes: { $in: bookboxIds }
            });
            // Notify all relevant users using the new notification system
            for (let i = 0; i < usersToNotify.length; i++) {
                if (usersToNotify[i].username !== user.username) {
                    yield notification_service_1.default.createNotification(usersToNotify[i]._id.toString(), ['book_request'], {
                        bookTitle: request.body.title
                    });
                }
            }
            const newRequest = new book_request_model_1.default({
                username: user.username,
                bookTitle: request.body.title,
                customMessage: request.body.customMessage,
            });
            yield newRequest.save();
            return newRequest;
        });
    },
    deleteBookRequest(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const requestId = request.params.id;
            const requestToDelete = yield book_request_model_1.default.findById(requestId);
            if (!requestToDelete) {
                throw (0, utilities_1.newErr)(404, 'Request not found');
            }
            yield requestToDelete.deleteOne();
        });
    },
    getBookRequests(request) {
        return __awaiter(this, void 0, void 0, function* () {
            let username = request.query.username;
            if (!username) {
                return book_request_model_1.default.find();
            }
            else {
                return book_request_model_1.default.find({ username: username });
            }
        });
    },
    // Get transaction history
    getTransactionHistory(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { username, bookTitle, bookboxId, limit } = request.query;
            let filter = {};
            if (username)
                filter.username = username;
            if (bookTitle)
                filter.bookTitle = new RegExp(bookTitle, 'i');
            if (bookboxId)
                filter.bookboxId = bookboxId;
            let query = transaction_model_1.default.find(filter).sort({ timestamp: -1 });
            if (limit) {
                query = query.limit(parseInt(limit.toString()));
            }
            return yield query.exec();
        });
    },
    // Create a transaction record
    createTransaction(username, action, bookTitle, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const transaction = new transaction_model_1.default({
                username,
                action,
                bookTitle,
                bookboxId
            });
            yield transaction.save();
            return transaction;
        });
    },
    // Calculate distance between two points using Haversine formula
    calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371; // Radius of the Earth in kilometers
        const dLat = this.deg2rad(lat2 - lat1);
        const dLon = this.deg2rad(lon2 - lon1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const distance = R * c; // Distance in kilometers
        return distance;
    },
    // Convert degrees to radians
    deg2rad(deg) {
        return deg * (Math.PI / 180);
    }
};
exports.default = bookService;
