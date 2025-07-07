import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from 'fastify';
import ThreadService from '../services/thread.service';
import Thread from "../models/thread.model";
import {clearCollectionSchema, threadSchema} from "../services/utilities";
import {broadcastMessage} from "../index";
import { ThreadCreateData, MessageCreateData, ReactionData } from "../types/thread.types";
import { AuthenticatedRequest } from "../types/common.types";


async function createThread(request : FastifyRequest, reply : FastifyReply) {
    try {
        const thread = await ThreadService.createThread(request as AuthenticatedRequest & { body: ThreadCreateData });
        reply.code(201).send({threadId: thread.id});
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 400;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
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
            Authorization: {type: 'string'}
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
                error: {type: 'string'}
            }
        },
        404: {
            description: 'Book not found',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }
};

async function deleteThread(request : FastifyRequest, reply : FastifyReply) {
    try {
        await ThreadService.deleteThread(request as { params: { threadId: string } });
        reply.code(204).send({ message: 'Thread deleted' });
        // Broadcast thread deletion
        const params = request.params as { threadId: string };
        broadcastMessage('threadDeleted', { threadId: params.threadId });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
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
            Authorization: {type: 'string'}
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
}

async function addThreadMessage(request : FastifyRequest, reply : FastifyReply) {
    try {
        const messageId = await ThreadService.addThreadMessage(request as AuthenticatedRequest & { body: MessageCreateData });
        reply.code(201).send(messageId);
        // Broadcast new message
        const body = request.body as MessageCreateData;
        broadcastMessage('newMessage', { messageId, threadId: body.threadId });
    } catch (error : unknown) {
        console.log(error);
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
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
            Authorization: {type: 'string'}
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
                error: {type: 'string'}
            }
        },
    }
};



interface ToggleMessageReactionParams extends RouteGenericInterface {
    Body: {
        reactIcon: string,
        threadId: string,
        messageId: string
    }
}
async function toggleMessageReaction(request : FastifyRequest<ToggleMessageReactionParams>, reply : FastifyReply) {
    try {
        const reaction = await ThreadService.toggleMessageReaction(request as AuthenticatedRequest & { body: ReactionData });
        reply.send({reaction : reaction});
        // Broadcast reaction
        broadcastMessage('messageReaction', { reaction, threadId: request.body.threadId });
    } catch (error : unknown) {
        console.log(error);
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(400).send({ error: message });
    }
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
            Authorization: {type: 'string'}
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
                error: {type: 'string'}
            }
        },
        500: {
            description: 'Internal server error',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }

};

async function searchThreads(request : FastifyRequest, reply : FastifyReply) {
    const threads = await ThreadService.searchThreads(request as { query: { q?: string; cls?: string; asc?: boolean } });
    reply.send(threads);
}

const searchThreadsSchema = {
    description: 'Search threads',
    tags: ['threads'],
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
            cls: { type: 'string' },
            asc: { type: 'boolean' }
        }
    },
    response: {
        200: {
            description: 'Threads found',
            type: 'object',
            properties: {
                threads: {
                    type: 'array',
                    items: threadSchema
                }
            }
        }
    }
};


interface GetThreadParams extends RouteGenericInterface {
    Params: {
        threadId: string
    }
}

async function getThread(request : FastifyRequest<GetThreadParams>, reply : FastifyReply) {
    const threadId = request.params.threadId;
    const thread = await Thread.findById(threadId);
    if (!thread) {
        reply.code(404).send({ error: 'Thread not found' });
        return;
    }
    reply.send(thread);
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
        200: {
            description: 'Thread found',
            ...threadSchema
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


async function clearCollection(request : FastifyRequest, reply : FastifyReply) {
    try {
        await ThreadService.clearCollection();
        reply.send({ message: 'Threads collection cleared' });
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({ error: message });
    }
}


interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request : FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request : FastifyRequest, reply: FastifyReply) => void;
}
export default async function threadRoutes(server: MyFastifyInstance) {
    server.get('/threads/:threadId', { schema : getThreadSchema }, getThread);
    server.get('/threads/search', { schema : searchThreadsSchema }, searchThreads);
    server.post('/threads/new', { preValidation: [server.authenticate], schema : createThreadSchema }, createThread);
    server.delete('/threads/:threadId', { preValidation: [server.authenticate], schema : deleteThreadSchema }, deleteThread);
    server.post('/threads/messages', { preValidation: [server.authenticate], schema : addMessageSchema }, addThreadMessage);
    server.post('/threads/messages/reactions', { preValidation: [server.authenticate], schema : toggleReactionSchema }, toggleMessageReaction);
    server.delete('/threads/clear', { preValidation: [server.adminAuthenticate], schema : clearCollectionSchema }, clearCollection);
}
