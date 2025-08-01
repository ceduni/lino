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
exports.default = requestRoutes;
const services_1 = require("../services");
const schemas_1 = require("../schemas");
function sendBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const userId = request.user.id; // Extract user ID from JWT token
            const { title, customMessage } = request.body;
            const response = yield services_1.RequestService.requestBookToUsers(userId, title, customMessage);
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
            const id = request.params.id;
            yield services_1.RequestService.deleteBookRequest(id);
            reply.code(204).send({ message: 'Book request deleted' });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function getBookRequests(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const username = request.query.username;
            const response = yield services_1.RequestService.getBookRequests(username);
            reply.code(200).send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function toggleSolvedStatus(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const id = request.params.id;
            const response = yield services_1.RequestService.toggleSolvedStatus(id);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function requestRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.post('/books/request', { preValidation: [server.authenticate], schema: schemas_1.sendBookRequestSchema }, sendBookRequest);
        server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: schemas_1.deleteBookRequestSchema }, deleteBookRequest);
        server.get('/books/requests', { schema: schemas_1.getBookRequestsSchema }, getBookRequests);
        server.patch('/books/request/:id/solve', { preValidation: [server.authenticate], schema: schemas_1.toggleSolvedStatusSchema }, toggleSolvedStatus);
    });
}
