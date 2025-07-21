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
const transaction_model_1 = __importDefault(require("../models/transaction.model"));
const notification_service_1 = __importDefault(require("./notification.service"));
const utilities_1 = require("./utilities");
const book_service_1 = __importDefault(require("./book.service"));
const borough_id_generator_1 = require("./borough.id.generator");
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
                longitude: bookBox.longitude,
                latitude: bookBox.latitude,
                boroughId: bookBox.boroughId,
                infoText: bookBox.infoText,
                books: bookBox.books,
            };
        });
    },
    // Add a book to a bookbox as a nested document
    addBook(request) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c;
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
            yield book_service_1.default.createTransaction(username, 'added', title, bookboxId);
            // Notify users about the new book
            yield notification_service_1.default.notifyRelevantUsers(username, newBook, ((_b = bookBox._id) === null || _b === void 0 ? void 0 : _b.toString()) || '');
            // Increment user's added books count
            if (request.user) {
                const user = yield user_model_1.default.findById(request.user.id);
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
    getBookFromBookBox(request) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
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
            yield book_service_1.default.createTransaction(username, 'took', book.title, bookboxId);
            // Increment user's saved books count
            if (request.user) {
                const user = yield user_model_1.default.findById(request.user.id);
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
    searchBookboxes(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const q= request.query.q;
            let bookBoxes = yield bookbox_model_1.default.find();
            if (q) {
                // Filter using regex for more flexibility
                const regex = new RegExp(q, 'i');
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
                const userLongitude = request.query.longitude;
                const userLatitude = request.query.latitude;
                if (!userLongitude || !userLatitude) {
                    throw (0, utilities_1.newErr)(401, 'Location is required for this classification');
                }
                bookBoxes.sort((a, b) => {
                    if (a.longitude && a.latitude && b.longitude && b.latitude) {
                        // calculate the distance between the user's location and the bookbox's location
                        const aDist = Math.sqrt(Math.pow((a.longitude - userLongitude), 2) + Math.pow((a.latitude - userLatitude), 2));
                        const bDist = Math.sqrt(Math.pow((b.longitude - userLongitude), 2) + Math.pow((b.latitude - userLatitude), 2));
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
            const boroughId = yield (0, borough_id_generator_1.getBoroughId)(request.body.latitude, request.body.longitude);
            const bookBox = new bookbox_model_1.default({
                name: request.body.name,
                books: [],
                image: request.body.image,
                longitude: request.body.longitude,
                latitude: request.body.latitude,
                boroughId: boroughId,
                infoText: request.body.infoText,
            });
            yield bookBox.save();
            return bookBox;
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield bookbox_model_1.default.deleteMany({});
        });
    },
    deleteBookBox(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBox = yield bookbox_model_1.default.findByIdAndDelete(request.params.bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            // Delete all transactions related to this bookbox
            yield transaction_model_1.default.deleteMany({ bookboxId: request.params.bookboxId });
            return { message: 'Bookbox deleted successfully' };
        });
    },
    updateBookBox(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBoxId = request.params.bookboxId;
            const updateData = request.body;
            const bookBox = yield bookbox_model_1.default.findById(bookBoxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            // Update the bookbox fields if they are provided
            if (updateData.name) {
                bookBox.name = updateData.name;
            }
            if (updateData.image) {
                bookBox.image = updateData.image;
            }
            if (updateData.longitude) {
                bookBox.longitude = updateData.longitude;
            }
            if (updateData.latitude) {
                bookBox.latitude = updateData.latitude;
            }
            if (updateData.latitude || updateData.longitude) {
                // If either latitude or longitude is updated, we need to update the boroughId
                const boroughId = yield (0, borough_id_generator_1.getBoroughId)(updateData.latitude || bookBox.latitude, updateData.longitude || bookBox.longitude);
                bookBox.boroughId = boroughId;
            }
            if (updateData.infoText) {
                bookBox.infoText = updateData.infoText;
            }
            yield bookBox.save();
            return {
                id: bookBox._id.toString(),
                name: bookBox.name,
                image: bookBox.image,
                longitude: bookBox.longitude,
                latitude: bookBox.latitude,
                boroughId: bookBox.boroughId,
                infoText: bookBox.infoText
            };
        });
    }
};
exports.default = bookboxService;
