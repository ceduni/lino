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
exports.default = bookBoxRoutes;
const bookbox_service_1 = __importDefault(require("../services/bookbox.service"));
const bookbox_schemas_1 = require("../schemas/bookbox.schemas");
function addBookToBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.addBook(request);
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
            const response = yield bookbox_service_1.default.getBookFromBookBox(request);
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
            const response = yield bookbox_service_1.default.getBookBox(request.params.bookboxId);
            reply.send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(404).send({ error: message });
        }
    });
}
function addNewBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.addNewBookbox(request);
            reply.code(201).send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(400).send({ error: message });
        }
    });
}
function searchBookboxes(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const bookboxes = yield bookbox_service_1.default.searchBookboxes(request);
            reply.send({ bookboxes: bookboxes });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(400).send({ error: message });
        }
    });
}
function deleteBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.deleteBookBox(request);
            reply.code(204).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function updateBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.updateBookBox(request);
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
        server.get('/bookboxes/:bookboxId', { schema: bookbox_schemas_1.getBookboxSchema }, getBookbox);
        server.get('/bookboxes/search', { schema: bookbox_schemas_1.searchBookboxesSchema }, searchBookboxes);
        server.post('/bookboxes/new', { preValidation: [server.adminAuthenticate], schema: bookbox_schemas_1.addNewBookboxSchema }, addNewBookbox);
        server.delete('/bookboxes/:bookboxId/books/:bookId', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: bookbox_schemas_1.getBookFromBookBoxSchema }, getBookFromBookBox);
        server.post('/bookboxes/:bookboxId/books/add', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: bookbox_schemas_1.addBookToBookboxSchema }, addBookToBookbox);
        server.delete('/bookboxes/:bookboxId', { preValidation: [server.adminAuthenticate], schema: bookbox_schemas_1.deleteBookBoxSchema }, deleteBookBox);
        server.put('/bookboxes/:bookboxId', { preValidation: [server.adminAuthenticate], schema: bookbox_schemas_1.updateBookBoxSchema }, updateBookBox);
    });
}
