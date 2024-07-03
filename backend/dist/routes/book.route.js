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
const book_service_1 = __importDefault(require("../services/book.service"));
function addBookToBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.addBook(request);
            reply.code(201).send(response);
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
}
function getBookFromBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const qrCode = request.params.bookQRCode;
        const bookboxId = request.params.bookboxId;
        try {
            const response = yield book_service_1.default.getBookFromBookBox(qrCode, request, bookboxId);
            reply.send(response);
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
}
function getBookInfoFromISBN(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const isbn = request.params.isbn;
            const book = yield book_service_1.default.getBookInfoFromISBN(isbn);
            reply.send(book);
        }
        catch (error) {
            reply.code(404).send({ error: error.message });
        }
    });
}
function searchBooks(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const books = yield book_service_1.default.searchBooks(request);
            reply.send({ books: books });
        }
        catch (error) {
            reply.code(404).send({ error: error.message });
        }
    });
}
function sendAlert(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.alertUsers(request);
            reply.send(response);
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
}
function getBook(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const book = yield book_service_1.default.getBook(request.params.id);
            reply.send(book);
        }
        catch (error) {
            reply.code(404).send({ error: error.message });
        }
    });
}
function getBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.getBookBox(request.params.bookboxId);
            reply.send(response);
        }
        catch (error) {
            reply.code(404).send({ error: error.message });
        }
    });
}
function addNewBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.addNewBookbox(request);
            reply.code(201).send(response);
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
}
function clearCollection(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield book_service_1.default.clearCollection();
            reply.send({ message: 'Books cleared' });
        }
        catch (error) {
            reply.code(500).send({ error: error.message });
        }
    });
}
function bookRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/books/get/:id', getBook);
        server.get('/books/bookbox/:bookboxId', getBookbox);
        server.get('/books/:bookQRCode/:bookboxId', { preValidation: [server.optionalAuthenticate] }, getBookFromBookBox);
        server.get('/books/:isbn', { preValidation: [server.optionalAuthenticate] }, getBookInfoFromISBN);
        server.get('/books/search', searchBooks);
        server.post('/books/add', { preValidation: [server.optionalAuthenticate] }, addBookToBookbox);
        server.post('/books/alert', { preValidation: [server.authenticate] }, sendAlert);
        server.post('/books/bookbox/new', { preValidation: [server.adminAuthenticate] }, addNewBookbox);
        server.delete('/books/clear', { preValidation: [server.adminAuthenticate] }, clearCollection);
    });
}
exports.default = bookRoutes;
