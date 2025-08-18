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
exports.default = searchRoutes;
const services_1 = require("../services");
const schemas_1 = require("../schemas");
function searchBooks(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { q, cls, asc, limit, page } = request.query;
            const results = yield services_1.SearchService.searchBooks(q, cls, asc, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function searchBookboxes(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { q, cls, asc, longitude, latitude, limit, page } = request.query;
            const results = yield services_1.SearchService.searchBookboxes(q, cls, asc, longitude, latitude, limit, page);
            reply.send(results);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(400).send({ error: message });
        }
    });
}
function findNearestBookboxes(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { longitude, latitude, maxDistance, searchByBorough, limit, page } = request.query;
            const results = yield services_1.SearchService.findNearestBookboxes(longitude, latitude, maxDistance, searchByBorough, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function searchThreads(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const { q, cls, asc, limit, page } = request.query;
        const results = yield services_1.SearchService.searchThreads(q, cls, asc, limit, page);
        reply.send(results);
    });
}
function searchMyManagedBookboxes(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const username = request.user.username;
            const { q, cls, asc, limit, page } = request.query;
            const results = yield services_1.SearchService.searchMyManagedBookboxes(username, q, cls, asc, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function searchTransactionHistory(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { username, bookTitle, bookboxId, limit, page } = request.query;
            const results = yield services_1.SearchService.searchTransactionHistory(username, bookTitle, bookboxId, limit, page);
            reply.send(results);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function searchIssues(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { username, bookboxId, status, oldestFirst, limit, page } = request.query;
            const results = yield services_1.SearchService.searchIssues(username, bookboxId, status, oldestFirst, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function searchUsers(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { q, limit, page } = request.query;
            const results = yield services_1.SearchService.searchUsers(q, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function searchBookRequests(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { q, filter, sortBy, sortOrder, limit, page } = request.query;
            let userId;
            if (request.user) {
                userId = request.user.id;
            }
            const results = yield services_1.SearchService.searchBookRequests(q, filter, sortBy, sortOrder, userId, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function searchRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/search/books', { schema: schemas_1.searchBooksSchema }, searchBooks);
        server.get('/search/bookboxes', { schema: schemas_1.searchBookboxesSchema }, searchBookboxes);
        server.get('/search/bookboxes/nearest', { schema: schemas_1.findNearestBookboxesSchema }, findNearestBookboxes);
        server.get('/search/threads', { schema: schemas_1.searchThreadsSchema }, searchThreads);
        server.get('/search/bookboxes/admin', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.searchMyManagedBookboxesSchema
        }, searchMyManagedBookboxes);
        server.get('/search/transactions', { schema: schemas_1.searchTransactionHistorySchema }, searchTransactionHistory);
        server.get('/search/issues', { schema: schemas_1.searchIssuesSchema }, searchIssues);
        server.get('/search/users', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.searchUsersSchema
        }, searchUsers);
        server.get('/search/requests', {
            preValidation: [server.optionalAuthenticate],
            schema: schemas_1.searchBookRequestsSchema
        }, searchBookRequests);
    });
}
