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
const thread_service_1 = __importDefault(require("../services/thread.service"));
const user_service_1 = __importDefault(require("../services/user.service"));
const thread_model_1 = __importDefault(require("../models/thread.model"));
function createThread(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        // @ts-ignore
        const username = yield user_service_1.default.getUserName(request.user.id);
        if (!username) {
            reply.code(401).send({ error: 'Unauthorized' });
            return;
        }
        const { bookId, title } = request.body;
        const thread = yield thread_service_1.default.createThread(bookId, username, title);
        reply.code(201).send({ threadId: thread._id });
    });
}
function addThreadMessage(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const thread = yield thread_model_1.default.findById(request.body.threadId);
        if (!thread) {
            reply.code(404).send({ error: 'Thread not found' });
            return;
        }
        // @ts-ignore
        const username = yield user_service_1.default.getUserName(request.user.id);
        if (!username) {
            reply.code(401).send({ error: 'Unauthorized' });
            return;
        }
        const { content, respondsTo } = request.body;
        const threadId = request.body.threadId;
        const message = yield thread_service_1.default.addThreadMessage(threadId, username, content, respondsTo);
        reply.code(201).send({ messageId: message._id });
    });
}
function toggleMessageReaction(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        // @ts-ignore
        const username = yield user_service_1.default.getUserName(request.user.id);
        if (!username) {
            reply.code(401).send({ error: 'Unauthorized' });
            return;
        }
        const { reactIcon, messageId, threadId } = request.body;
        try {
            const reaction = yield thread_service_1.default.toggleMessageReaction(threadId, messageId, username, reactIcon);
            reply.send({ reaction: reaction });
        }
        catch (error) {
            console.error('Error adding reaction:', error);
            reply.code(500).send({ error: 'Internal server error' });
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
        yield thread_service_1.default.clearCollection();
        reply.send({ message: 'Threads collection cleared' });
    });
}
function threadRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/threads/:threadId', getThread);
        server.get('/threads/search', searchThreads);
        server.post('/threads/new', { preValidation: [server.authenticate] }, createThread);
        server.post('/threads/messages', { preValidation: [server.authenticate] }, addThreadMessage);
        server.post('/threads/messages/reactions', { preValidation: [server.authenticate] }, toggleMessageReaction);
        server.delete('/threads/clear', { preValidation: [server.adminAuthenticate] }, clearCollection);
    });
}
exports.default = threadRoutes;
