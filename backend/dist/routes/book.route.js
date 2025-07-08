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
exports.default = bookRoutes;
const book_service_1 = __importDefault(require("../services/book.service"));
const book_schemas_1 = require("../schemas/book.schemas");
function getBookInfoFromISBN(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const book = yield book_service_1.default.getBookInfoFromISBN(request);
            reply.send(book);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function sendBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.requestBookToUsers(request);
            reply.code(201).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function deleteBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield book_service_1.default.deleteBookRequest(request);
            reply.code(204).send({ message: 'Book request deleted' });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(404).send({ error: message });
        }
    });
}
function getBookRequests(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.getBookRequests(request);
            reply.code(200).send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function getTransactionHistory(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const transactions = yield book_service_1.default.getTransactionHistory(request);
            reply.send({ transactions });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function bookRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/books/:id', { schema: book_schemas_1.getBookSchema }, getBook);
        server.get('/books/info-from-isbn/:isbn', { preValidation: [server.optionalAuthenticate], schema: book_schemas_1.getBookInfoFromISBNSchema }, getBookInfoFromISBN);
        server.get('/books/search', { schema: book_schemas_1.searchBooksSchema }, searchBooks);
        server.post('/books/request', { preValidation: [server.authenticate], schema: book_schemas_1.sendBookRequestSchema }, sendBookRequest);
        server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: book_schemas_1.deleteBookRequestSchema }, deleteBookRequest);
        server.get('/books/requests', { schema: book_schemas_1.getBookRequestsSchema }, getBookRequests);
        server.get('/books/transactions', { schema: book_schemas_1.getTransactionHistorySchema }, getTransactionHistory);
    });
}
