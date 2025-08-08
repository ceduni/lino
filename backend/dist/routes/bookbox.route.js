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
exports.default = bookBoxRoutes;
const services_1 = require("../services");
const schemas_1 = require("../schemas");
function addBookToBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = request.user;
            const userId = (user === null || user === void 0 ? void 0 : user.id) || undefined;
            const bookboxId = request.params.bookboxId;
            const { title, isbn, authors, description, coverImage, publisher, parutionYear, pages, categories } = request.body;
            const response = yield services_1.BookboxService.addBook({
                bookboxId,
                title,
                isbn,
                authors,
                description,
                coverImage,
                publisher,
                parutionYear,
                pages,
                categories,
                userId
            });
            reply.code(201).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function getBookFromBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = request.user;
            const userId = (user === null || user === void 0 ? void 0 : user.id) || undefined;
            const { bookId, bookboxId } = request.params;
            const response = yield services_1.BookboxService.getBookFromBookBox(bookboxId, bookId, userId);
            reply.send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function getBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const bookboxId = request.params.bookboxId;
            const response = yield services_1.BookboxService.getBookBox(bookboxId);
            reply.send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(404).send({ error: message });
        }
    });
}
function followBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = request.user;
            const userId = user.id;
            const bookboxId = request.params.bookboxId;
            const response = yield services_1.BookboxService.followBookBox(userId, bookboxId);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function unfollowBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = request.user;
            const userId = user.id;
            const bookboxId = request.params.bookboxId;
            const response = yield services_1.BookboxService.unfollowBookBox(userId, bookboxId);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function bookBoxRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        // Public routes
        server.get('/bookboxes/:bookboxId', { schema: schemas_1.getBookboxSchema }, getBookbox);
        // User routes (authenticated)
        server.post('/bookboxes/follow/:bookboxId', { preValidation: [server.authenticate], schema: schemas_1.followBookBoxSchema }, followBookBox);
        server.delete('/bookboxes/unfollow/:bookboxId', { preValidation: [server.authenticate], schema: schemas_1.unfollowBookBoxSchema }, unfollowBookBox);
        // Book manipulation routes (special token required)
        server.delete('/bookboxes/:bookboxId/books/:bookId', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: schemas_1.removeBookFromBookBoxSchema }, getBookFromBookBox);
        server.post('/bookboxes/:bookboxId/books/add', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: schemas_1.addBookToBookboxSchema }, addBookToBookbox);
    });
}
