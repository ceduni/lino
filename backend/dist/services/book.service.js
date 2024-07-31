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
const book_model_1 = __importDefault(require("../models/book.model"));
const user_model_1 = __importDefault(require("../models/user.model"));
const bookbox_model_1 = __importDefault(require("../models/bookbox.model"));
const book_request_model_1 = __importDefault(require("../models/book.request.model"));
const user_service_1 = require("./user.service");
const utilities_1 = require("./utilities");
const bookService = {
    getBookBox(bookBoxId) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookBox = yield bookbox_model_1.default.findById(bookBoxId);
            if (!bookBox) {
                throw new Error('Bookbox not found');
            }
            const books = [];
            for (const bookId of bookBox.books) {
                const book = yield book_model_1.default.findById(bookId);
                if (book) {
                    books.push(book);
                }
            }
            return {
                id: bookBox.id,
                name: bookBox.name,
                image: bookBox.image,
                location: bookBox.location,
                infoText: bookBox.infoText,
                books: books,
            };
        });
    },
    // Helper function to fetch or create a book
    addBook(request) {
        return __awaiter(this, void 0, void 0, function* () {
            let book = yield book_model_1.default.findOne({ qrCodeId: request.body.qrCodeId });
            if (!book) {
                book = new book_model_1.default({
                    qrCodeId: request.body.qrCodeId,
                    isbn: request.body.isbn,
                    title: request.body.title,
                    authors: request.body.authors,
                    description: request.body.description,
                    coverImage: request.body.coverImage,
                    publisher: request.body.publisher,
                    parutionYear: request.body.parutionYear,
                    pages: request.body.pages,
                    categories: request.body.categories,
                });
            }
            if (!book.qrCodeId) {
                throw (0, utilities_1.newErr)(400, 'Book\'s QR code ID is required');
            }
            if (!book.title) {
                throw (0, utilities_1.newErr)(400, 'Book\'s title is required');
            }
            let bookBox = yield bookbox_model_1.default.findById(request.body.bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            // check if the book is already in a bookbox somewhere
            const bookBoxes = yield bookbox_model_1.default.find({ books: book.id });
            if (bookBoxes.length > 0) {
                throw (0, utilities_1.newErr)(400, 'Book is supposed to be in the book box ' + bookBoxes[0].name);
            }
            bookBox.books.push(book.id);
            yield this.updateBooks(book, request, true);
            yield this.notifyAllUsers(book, 'added to', bookBox.name);
            yield book.save();
            yield bookBox.save();
            yield this.updateUserEcoImpact(request, book.id);
            // send a notification to the user who requested the book
            let requests = yield book_request_model_1.default.find();
            // Filter requests using regex to match similar titles
            const regex = new RegExp(book.title, 'i');
            requests = requests.filter(request => regex.test(request.bookTitle));
            for (let i = 0; i < requests.length; i++) {
                yield (0, user_service_1.notifyUser)(requests[i].username, "Book notification", `The book "${book.title}" has been added to the bookbox "${bookBox.name}" to fulfill your request !`);
            }
            return { bookId: book.id, books: bookBox.books };
        });
    },
    getBookFromBookBox(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const qrCode = request.params.bookQRCode;
            const bookboxId = request.params.bookboxId;
            // check if the book exists
            let book = yield book_model_1.default.findOne({ qrCodeId: qrCode });
            if (!book) {
                throw (0, utilities_1.newErr)(404, 'Book not found');
            }
            // check if the bookbox exists
            let bookBox = yield bookbox_model_1.default.findById(bookboxId);
            if (!bookBox) {
                throw (0, utilities_1.newErr)(404, 'Bookbox not found');
            }
            // check if the book is in the bookbox
            if (bookBox.books.includes(book.id)) {
                bookBox.books.splice(bookBox.books.indexOf(book.id), 1);
            }
            else {
                throw (0, utilities_1.newErr)(404, 'Book not found in bookbox');
            }
            yield this.updateBooks(book, request, false);
            yield this.notifyAllUsers(book, 'removed from', bookBox.name);
            yield book.save();
            yield bookBox.save();
            yield this.updateUserEcoImpact(request, book.id);
            return { book: book, books: bookBox.books };
        });
    },
    updateUserEcoImpact(request, bookId) {
        return __awaiter(this, void 0, void 0, function* () {
            // if user is authenticated, update the user's ecological impact
            if (request.user) {
                // @ts-ignore
                const userId = request.user.id;
                let user = yield user_model_1.default.findById(userId);
                if (user) {
                    if (!user.trackedBooks.includes(bookId)) {
                        // add the book to the user's tracked books if it's not already there
                        user.trackedBooks.push(bookId);
                        // the user can't gain ecological impact from the same book twice
                        // @ts-ignore
                        user.ecologicalImpact.carbonSavings += 27.71;
                        // @ts-ignore
                        user.ecologicalImpact.savedWater += 2000;
                        // @ts-ignore
                        user.ecologicalImpact.savedTrees += 0.005;
                    }
                    yield user.save();
                }
            }
        });
    },
    updateBooks(book, request, given) {
        return __awaiter(this, void 0, void 0, function* () {
            if (request.user) {
                // Push the user's username and the current timestamp to the book's history
                // @ts-ignore
                const userId = request.user.id;
                const user = yield user_model_1.default.findById(userId);
                if (!user) {
                    throw (0, utilities_1.newErr)(404, 'User not found');
                }
                const username = user.username;
                if (given) { // if the book is given
                    book.givenHistory.push({ username: username, timestamp: new Date() });
                    // push in the user's book history
                    user.bookHistory.push({ bookId: book.id, timestamp: new Date(), given: true });
                }
                else { // if the book is taken
                    book.takenHistory.push({ username: username, timestamp: new Date() });
                    // push in the user's book history
                    user.bookHistory.push({ bookId: book.id, timestamp: new Date(), given: false });
                }
            }
            else { // if the user is not authenticated, username is 'guest'
                if (given) { // if the book is given
                    book.givenHistory.push({ username: "guest", timestamp: new Date() });
                }
                else { // if the book is taken
                    book.takenHistory.push({ username: "guest", timestamp: new Date() });
                }
            }
            let books = yield book_model_1.default.find();
            // Filter books using regex to match similar titles
            const regex = new RegExp(book.title, 'i');
            books = books.filter(b => regex.test(b.title));
            for (let i = 0; i < books.length; i++) {
                // Update the dateLastAction field for all books with the same title
                // to indicate that this book has been looked at recently
                // @ts-ignore
                books[i].dateLastAction = Date.now();
                yield books[i].save();
            }
        });
    },
    getBookInfoFromISBN(request) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const isbn = request.params.isbn;
            const response = yield axios_1.default.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}`);
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
    // Function that searches for books based on the query parameters
    searchBooks(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { cat, kw, pmt, pg, bf, py, pub, bbid, cls = 'by title', asc = true } = request.query;
            let filter = {};
            if (cat) {
                const categories = Array.isArray(cat) ? cat : [cat];
                const categoryArray = categories.map((c) => new RegExp(c.trim(), 'i'));
                filter.categories = { $in: categoryArray };
            }
            if (kw) {
                const regex = new RegExp(kw, 'i');
                filter.$or = [
                    { title: regex },
                    { authors: regex }
                ];
            }
            if (py) {
                filter.parutionYear = bf ? { $lte: py } : { $gte: py };
            }
            if (pub) {
                filter.publisher = new RegExp(pub, 'i');
            }
            if (bbid) {
                const bookBox = yield bookbox_model_1.default.findById(bbid);
                if (!bookBox) {
                    throw new Error('Bookbox not found');
                }
                filter._id = { $in: bookBox.books };
            }
            let books = yield book_model_1.default.find(filter);
            if (pg) {
                const pageCount = parseInt(pg);
                books = books.filter((book) => {
                    const bookPages = book.pages || 0;
                    return pmt ? bookPages >= pageCount : bookPages <= pageCount;
                });
            }
            // Sorting
            const sortOptions = {};
            if (cls === 'by title') {
                sortOptions.title = asc ? 1 : -1;
            }
            else if (cls === 'by author') {
                sortOptions['authors.0'] = asc ? 1 : -1;
            }
            else if (cls === 'by year') {
                sortOptions.parutionYear = asc ? 1 : -1;
            }
            else if (cls === 'by recent activity') {
                sortOptions.dateLastAction = asc ? 1 : -1;
            }
            books = yield book_model_1.default.find(filter).sort(sortOptions);
            const bookBoxes = yield bookbox_model_1.default.find();
            const finalBooks = [];
            for (let i = 0; i < books.length; i++) {
                const book = books[i].toObject();
                // @ts-ignore
                book.bookboxPresence = bookBoxes.filter((box) => box.books.includes(book._id.toString())).map(box => box._id);
                finalBooks.push(book);
            }
            return finalBooks;
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
                    // calculate the distance between the user's location and the bookbox's location
                    const aDist = Math.sqrt(Math.pow((aLoc[0] - selfLoc[0]), 2) + Math.pow((aLoc[1] - selfLoc[1]), 2));
                    const bDist = Math.sqrt(Math.pow((bLoc[0] - selfLoc[0]), 2) + Math.pow((bLoc[1] - selfLoc[1]), 2));
                    // sort in ascending or descending order of distance
                    return asc ? aDist - bDist : bDist - aDist;
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
    getBook(id) {
        return __awaiter(this, void 0, void 0, function* () {
            return book_model_1.default.findById(id);
        });
    },
    requestBookToUsers(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(request.user.id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const users = yield user_model_1.default.find({ getAlerted: true });
            for (let i = 0; i < users.length; i++) {
                if (users[i].username !== user.username) {
                    yield (0, user_service_1.notifyUser)(users[i].id, "Book request", `The user ${user.username} wants to get the book "${request.body.title}" ! If you have it, please feel free to add it to one of our book boxes !`);
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
    // Function that returns 1 if the book is relevant to the user by his keywords, 0 otherwise
    getBookRelevance(book, user) {
        return __awaiter(this, void 0, void 0, function* () {
            // @ts-ignore
            const keywords = user.notificationKeyWords.map(keyword => new RegExp(keyword, 'i'));
            const properties = [book.title, ...book.authors, ...book.categories];
            for (let i = 0; i < properties.length; i++) {
                for (let j = 0; j < keywords.length; j++) {
                    if (keywords[j].test(properties[i])) {
                        return 1;
                    }
                }
            }
            return 0;
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
    notifyAllUsers(book, action, bookBoxName) {
        return __awaiter(this, void 0, void 0, function* () {
            const users = yield user_model_1.default.find();
            for (let i = 0; i < users.length; i++) {
                const relevance = yield this.getBookRelevance(book, users[i]);
                // Notify the user if the book is relevant to him or if it's one of his favorite books
                if (relevance > 0 || users[i].favoriteBooks.includes(book.id)) {
                    yield (0, user_service_1.notifyUser)(users[i].id, "Book notification", `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
                }
            }
        });
    },
    getBookRequests(request) {
        return __awaiter(this, void 0, void 0, function* () {
            let username = request.params.username;
            if (!username) {
                return book_request_model_1.default.find();
            }
            else {
                return book_request_model_1.default.find({ username: username });
            }
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield book_model_1.default.deleteMany({});
            yield bookbox_model_1.default.deleteMany({});
        });
    }
};
exports.default = bookService;
