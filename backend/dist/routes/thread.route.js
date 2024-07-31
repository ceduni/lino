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
const thread_model_1 = __importDefault(require("../models/thread.model"));
const utilities_1 = require("../services/utilities");
function createThread(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const thread = yield thread_service_1.default.createThread(request);
            reply.code(201).send({ threadId: thread.id });
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
}
const createThreadSchema = {
    description: 'Create a new thread',
    tags: ['threads'],
    body: {
        type: 'object',
        required: ['bookId', 'title'],
        properties: {
            bookId: { type: 'string' },
            title: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: { type: 'string' }
        }
    },
    response: {
        201: {
            description: 'Thread created successfully',
            type: 'object',
            properties: {
                threadId: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Bad request',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Book not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function deleteThread(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield thread_service_1.default.deleteThread(request);
            reply.code(204).send({ message: 'Thread deleted' });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const deleteThreadSchema = {
    description: 'Delete a thread',
    tags: ['threads'],
    params: {
        type: 'object',
        required: ['threadId'],
        properties: {
            threadId: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: { type: 'string' }
        }
    },
    response: {
        204: {
            description: 'Thread deleted',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Thread not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function addThreadMessage(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const messageId = yield thread_service_1.default.addThreadMessage(request);
            reply.code(201).send(messageId);
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const addMessageSchema = {
    description: 'Add a new message to a thread',
    tags: ['threads', 'messages'],
    body: {
        type: 'object',
        required: ['threadId', 'content'],
        properties: {
            threadId: { type: 'string' },
            content: { type: 'string' },
            respondsTo: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: { type: 'string' }
        }
    },
    response: {
        201: {
            description: 'Message added successfully',
            type: 'object',
            properties: {
                messageId: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Bad request',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Thread, parent message or user not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function toggleMessageReaction(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const reaction = yield thread_service_1.default.toggleMessageReaction(request);
            reply.send({ reaction: reaction });
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
}
const toggleReactionSchema = {
    description: 'Toggle a reaction to a message',
    tags: ['threads', 'messages'],
    body: {
        type: 'object',
        required: ['reactIcon', 'threadId', 'messageId'],
        properties: {
            reactIcon: { type: 'string' },
            threadId: { type: 'string' },
            messageId: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Reaction added successfully',
            type: 'object',
            properties: {
                reaction: {
                    type: 'object',
                    properties: {
                        _id: { type: 'string' },
                        username: { type: 'string' },
                        reactIcon: { type: 'string' },
                        timestamp: { type: 'string' }
                    }
                }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Bad request',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Thread or message not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function searchThreads(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const threads = yield thread_service_1.default.searchThreads(request);
        reply.send(threads);
    });
}
const searchThreadsSchema = {
    description: 'Search threads',
    tags: ['threads'],
    querystring: {
        q: { type: 'string' },
        cls: { type: 'string' },
        asc: { type: 'boolean' },
    },
    response: {
        200: {
            description: 'Threads found',
            type: 'object',
            properties: {
                threads: {
                    type: 'array',
                    items: utilities_1.threadSchema
                }
            }
        }
    }
};
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
const getThreadSchema = {
    description: 'Get a thread by id',
    tags: ['threads'],
    params: {
        type: 'object',
        required: ['threadId'],
        properties: {
            threadId: { type: 'string' }
        }
    },
    response: {
        200: Object.assign({ description: 'Thread found' }, utilities_1.threadSchema),
        404: {
            description: 'Thread not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function clearCollection(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield thread_service_1.default.clearCollection();
            reply.send({ message: 'Threads collection cleared' });
        }
        catch (error) {
            reply.code(500).send({ error: error.message });
        }
    });
}
function threadRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/threads/:threadId', { schema: getThreadSchema }, getThread);
        server.get('/threads/search', { schema: searchThreadsSchema }, searchThreads);
        server.post('/threads/new', { preValidation: [server.authenticate], schema: createThreadSchema }, createThread);
        server.delete('/threads/:threadId', { preValidation: [server.authenticate], schema: deleteThreadSchema }, deleteThread);
        server.post('/threads/messages', { preValidation: [server.authenticate], schema: addMessageSchema }, addThreadMessage);
        server.post('/threads/messages/reactions', { preValidation: [server.authenticate], schema: toggleReactionSchema }, toggleMessageReaction);
        server.delete('/threads/clear', { preValidation: [server.adminAuthenticate], schema: utilities_1.clearCollectionSchema }, clearCollection);
    });
}
exports.default = threadRoutes;
