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
exports.default = bookRoutes;
const services_1 = require("../services");
const schemas_1 = require("../schemas");
function getBookInfoFromISBN(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const isbn = request.params.isbn;
            const book = yield services_1.BookService.getBookInfoFromISBN(isbn);
            reply.send(book);
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
            const id = request.params.id;
            const book = yield services_1.BookService.getBook(id);
            reply.send(book);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(404).send({ error: message });
        }
    });
}
function bookRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/books/:id', { schema: schemas_1.getBookSchema }, getBook);
        server.get('/books/info-from-isbn/:isbn', { preValidation: [server.optionalAuthenticate], schema: schemas_1.getBookInfoFromISBNSchema }, getBookInfoFromISBN);
    });
}
