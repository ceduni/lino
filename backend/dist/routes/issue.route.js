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
exports.default = issueRoutes;
const schemas_1 = require("../schemas");
const services_1 = require("../services");
function createIssue(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = request.user;
            const userId = (user === null || user === void 0 ? void 0 : user.id) || undefined;
            let username, email;
            if (!userId) {
                // Get email from request body if user is not authenticated
                email = request.body.email;
                username = 'guest'; // Default username for unauthenticated users
            }
            else {
                // Use the authenticated user's email
                const user = yield services_1.UserService.getUser(userId);
                email = user === null || user === void 0 ? void 0 : user.email;
                username = user === null || user === void 0 ? void 0 : user.username;
            }
            if (!email) {
                reply.code(400).send({ error: 'Email is required' });
                return;
            }
            const { bookboxId, subject, description } = request.body;
            const issue = yield services_1.IssueService.createIssue({ username, email, bookboxId, subject, description });
            reply.code(201).send(issue);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function getIssue(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const issueId = request.params.id;
            const issue = yield services_1.IssueService.getIssue(issueId);
            reply.send(issue);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function investigateIssue(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const issueId = request.params.id;
            const issue = yield services_1.IssueService.investigateIssue(issueId);
            reply.send(issue);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function closeIssue(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const issueId = request.params.id;
            const issue = yield services_1.IssueService.closeIssue(issueId);
            reply.send(issue);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function reopenIssue(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const issueId = request.params.id;
            const issue = yield services_1.IssueService.reopenIssue(issueId);
            reply.send(issue);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function issueRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.post('/issues', { preValidation: [server.optionalAuthenticate], schema: schemas_1.createIssueSchema }, createIssue);
        server.get('/issues/:id', { schema: schemas_1.getIssueSchema }, getIssue);
        server.put('/issues/:id/investigate', { preValidation: [server.adminAuthenticate], schema: schemas_1.investigateIssueSchema }, investigateIssue);
        server.put('/issues/:id/close', { preValidation: [server.adminAuthenticate], schema: schemas_1.closeIssueSchema }, closeIssue);
        server.put('/issues/:id/reopen', { preValidation: [server.adminAuthenticate], schema: schemas_1.reopenIssueSchema }, reopenIssue);
    });
}
