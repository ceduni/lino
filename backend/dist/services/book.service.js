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
const models_1 = require("../models");
const utilities_1 = require("../utilities/utilities");
const bookService = {
    getBookInfoFromISBN(isbn) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const response = yield axios_1.default.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}&key=${process.env.GOOGLE_API_KEY}`);
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
    getBook(id) {
        return __awaiter(this, void 0, void 0, function* () {
            // Use aggregation pipeline to efficiently find book by ID
            const pipeline = [
                // Filter out inactive bookboxes first
                { $match: { isActive: true } },
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
            const results = yield models_1.BookBox.aggregate(pipeline);
            return results.length > 0 ? results[0] : null;
        });
    },
};
exports.default = bookService;
