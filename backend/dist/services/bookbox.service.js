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
const bookbox_model_1 = __importDefault(require("../models/bookbox.model"));
const user_model_1 = __importDefault(require("../models/user.model"));
const book_request_model_1 = __importDefault(require("../models/book.request.model"));
const user_service_1 = require("./user.service");
const utilities_1 = require("./utilities");
const book_service_1 = __importDefault(require("./book.service"));
const bookboxService = {
    getBookBox(bookBoxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBox = yield bookbox_model_1.default.findById(bookBoxId);
            if (!bookBox) {
                throw new Error('Bookbox not found');
            }
            return {
                id: bookBox.id,
                name: bookBox.name,
                image: bookBox.image,
                location: bookBox.location,
                infoText: bookBox.infoText,
                books: bookBox.books,
            };
        });
    },
    // Add a book to a bookbox as a nested document
    addBook(request) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            const { title, isbn, authors, description, coverImage, publisher, parutionYear, pages, categories } = request.body;
            const { bookboxId } = request.params;
            if (!title) {
                throw (0, utilities_1.newErr)(400, 'Book title is required');
            }
            let bookBox = yield bookbox_model_1.default.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
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
            const username = request.user ? ((_a = (yield user_model_1.default.findById(request.user.id))) === null || _a === void 0 ? void 0 : _a.username) || 'guest' : 'guest';
            yield book_service_1.default.createTransaction(username, 'added', title, bookBox.name);
            // Notify users about the new book
            yield this.notifyRelevantUsers(newBook, 'added to', bookBox.name);
            // Increment user's added books count
            if (request.user) {
                const user = yield user_model_1.default.findById(request.user.id);
                if (user) {
                    user.numSavedBooks++;
                    yield user.save();
                }
            }
            return { bookId: (_b = addedBook._id) === null || _b === void 0 ? void 0 : _b.toString(), books: bookBox.books };
        });
    },
    getBookFromBookBox(request) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            const bookId = request.params.bookId;
            const bookboxId = request.params.bookboxId;
            // Find the bookbox
            let bookBox = yield bookbox_model_1.default.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
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
            const username = request.user ? ((_a = (yield user_model_1.default.findById(request.user.id))) === null || _a === void 0 ? void 0 : _a.username) || 'guest' : 'guest';
            yield book_service_1.default.createTransaction(username, 'took', book.title, bookBox.name);
            // Notify users about the book removal
            const bookForNotification = {
                _id: (_b = book._id) === null || _b === void 0 ? void 0 : _b.toString(),
                isbn: book.isbn || "Unknown ISBN",
                title: book.title,
                authors: book.authors || [],
                description: book.description || "No description available",
                coverImage: book.coverImage || "No cover image",
                publisher: book.publisher || "Unknown Publisher",
                categories: book.categories || [],
                parutionYear: book.parutionYear || undefined,
                pages: book.pages || undefined,
                dateAdded: book.dateAdded || new Date(),
            };
            yield this.notifyRelevantUsers(bookForNotification, 'removed from', bookBox.name);
            // Increment user's saved books count
            if (request.user) {
                const user = yield user_model_1.default.findById(request.user.id);
                if (user) {
                    user.numSavedBooks++;
                    yield user.save();
                }
            }
            return { book: book, books: bookBox.books };
        });
    },
    searchBookboxes(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const kw = request.query.kw;
            let bookBoxes = yield bookbox_model_1.default.find();
            if (kw) {
                // Filter using regex for more flexibility
                const regex = new RegExp(kw, 'i');
                bookBoxes = bookBoxes.filter((bookBox) => regex.test(bookBox.name) || regex.test(bookBox.infoText || ''));
            }
            const cls = request.query.cls;
            const asc = request.query.asc; // Boolean
            if (cls === 'by name') {
                bookBoxes.sort((a, b) => {
                    return asc ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
                });
            }
            else if (cls === 'by location') {
                const selfLoc = [request.query.longitude, request.query.latitude];
                if (!selfLoc[0] || !selfLoc[1]) {
                    throw (0, utilities_1.newErr)(401, 'Location is required for this classification');
                }
                bookBoxes.sort((a, b) => {
                    const aLoc = a.location;
                    const bLoc = b.location;
                    if (aLoc && bLoc && selfLoc[0] && selfLoc[1]) {
                        // calculate the distance between the user's location and the bookbox's location
                        const aDist = Math.sqrt(Math.pow((aLoc[0] - selfLoc[0]), 2) + Math.pow((aLoc[1] - selfLoc[1]), 2));
                        const bDist = Math.sqrt(Math.pow((bLoc[0] - selfLoc[0]), 2) + Math.pow((bLoc[1] - selfLoc[1]), 2));
                        // sort in ascending or descending order of distance
                        return asc ? aDist - bDist : bDist - aDist;
                    }
                    return 0;
                });
            }
            else if (cls === 'by number of books') {
                bookBoxes.sort((a, b) => {
                    return asc ? a.books.length - b.books.length : b.books.length - a.books.length;
                });
            }
            // only return the ids of the bookboxes
            const bookBoxIds = bookBoxes.map((bookBox) => bookBox._id.toString());
            // get the full bookbox objects
            const finalBookBoxes = [];
            for (let i = 0; i < bookBoxIds.length; i++) {
                finalBookBoxes.push(yield this.getBookBox(bookBoxIds[i]));
            }
            return finalBookBoxes;
        });
    },
    addNewBookbox(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBox = new bookbox_model_1.default({
                name: request.body.name,
                books: [],
                image: request.body.image,
                location: [request.body.longitude, request.body.latitude],
                infoText: request.body.infoText,
            });
            yield bookBox.save();
            return bookBox;
        });
    },
    // Function that returns 1 if the book is relevant to the user by his keywords
    // or if he put that book title in a request, 0 otherwise
    getBookRelevance(book, user) {
        return __awaiter(this, void 0, void 0, function* () {
            const keywords = user.notificationKeyWords.map((keyword) => new RegExp(keyword, 'i'));
            const properties = [book.title, ...book.authors, ...book.categories];
            for (let i = 0; i < properties.length; i++) {
                for (let j = 0; j < keywords.length; j++) {
                    if (keywords[j].test(properties[i])) {
                        return 1;
                    }
                }
            }
            const requests = yield book_request_model_1.default.find();
            const regex = new RegExp(book.title, 'i');
            const matchingRequests = requests.filter(req => regex.test(req.bookTitle));
            for (const req of matchingRequests) {
                if (req.username === user.username) {
                    return 1; // User has requested this book
                }
            }
            return 0;
        });
    },
    notifyRelevantUsers(book, action, bookBoxName) {
        return __awaiter(this, void 0, void 0, function* () {
            const users = yield user_model_1.default.find();
            for (let i = 0; i < users.length; i++) {
                const relevance = yield this.getBookRelevance(book, users[i]);
                // Notify the user if the book is relevant to him
                if (relevance > 0) {
                    yield (0, user_service_1.notifyUser)(users[i].id, "Book notification", `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
                }
            }
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield bookbox_model_1.default.deleteMany({});
        });
    }
};
exports.default = bookboxService;
