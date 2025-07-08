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
exports.default = threadRoutes;
const thread_service_1 = __importDefault(require("../services/thread.service"));
const thread_model_1 = __importDefault(require("../models/thread.model"));
const thread_schemas_1 = require("../schemas/thread.schemas");
const user_schemas_1 = require("../schemas/user.schemas");
const index_1 = require("../index");
function createThread(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const thread = yield thread_service_1.default.createThread(request);
            reply.code(201).send({ threadId: thread.id });
        }
        catch (error) {
            const statusCode = error.statusCode || 400;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function deleteThread(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield thread_service_1.default.deleteThread(request);
            reply.code(204).send({ message: 'Thread deleted' });
            // Broadcast thread deletion
            const params = request.params;
            (0, index_1.broadcastMessage)('threadDeleted', { threadId: params.threadId });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function addThreadMessage(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const messageId = yield thread_service_1.default.addThreadMessage(request);
            reply.code(201).send(messageId);
            // Broadcast new message
            const body = request.body;
            (0, index_1.broadcastMessage)('newMessage', { messageId, threadId: body.threadId });
        }
        catch (error) {
            console.log(error);
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function toggleMessageReaction(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const reaction = yield thread_service_1.default.toggleMessageReaction(request);
            reply.send({ reaction: reaction });
            // Broadcast reaction
            (0, index_1.broadcastMessage)('messageReaction', { reaction, threadId: request.body.threadId });
        }
        catch (error) {
            console.log(error);
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(400).send({ error: message });
        }
    });
}
function searchThreads(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const threads = yield thread_service_1.default.searchThreads(request);
        reply.send(threads);
    });
}
function getThread(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const threadId = request.params.threadId;
        const thread = yield thread_model_1.default.findById(threadId);
        if (!thread) {
            reply.code(404).send({ error: 'Thread not found' });
            return;
        }
        reply.send(thread);
    });
}
function clearCollection(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield thread_service_1.default.clearCollection();
            reply.send({ message: 'Threads collection cleared' });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function threadRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/threads/:threadId', { schema: thread_schemas_1.getThreadSchema }, getThread);
        server.get('/threads/search', { schema: thread_schemas_1.searchThreadsSchema }, searchThreads);
        server.post('/threads/new', { preValidation: [server.authenticate], schema: thread_schemas_1.createThreadSchema }, createThread);
        server.delete('/threads/:threadId', { preValidation: [server.authenticate], schema: thread_schemas_1.deleteThreadSchema }, deleteThread);
        server.post('/threads/messages', { preValidation: [server.authenticate], schema: thread_schemas_1.addMessageSchema }, addThreadMessage);
        server.post('/threads/messages/reactions', { preValidation: [server.authenticate], schema: thread_schemas_1.toggleReactionSchema }, toggleMessageReaction);
        server.delete('/threads/clear', { preValidation: [server.adminAuthenticate], schema: user_schemas_1.clearCollectionSchema }, clearCollection);
    });
}
