import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from 'fastify';
import ThreadService from '../services/thread.service';
import UserService from "../services/user.service";
import Thread from "../models/thread.model";


interface CreateThreadParams extends RouteGenericInterface {
    Body: {
        bookId: string,
        title: string
    }
}
async function createThread(request : FastifyRequest<CreateThreadParams>, reply : FastifyReply) {
    // @ts-ignore
    const username = await UserService.getUserName(request.user.id);
    if (!username) {
        reply.code(401).send({ error: 'Unauthorized' });
        return;
    }
    const { bookId, title } = request.body;
    const thread = await ThreadService.createThread(bookId, username, title);
    reply.code(201).send({threadId: thread._id});
}

interface AddThreadMessageParams extends RouteGenericInterface {
    Body: {
        threadId: string,
        content: string,
        respondsTo: string
    }
}
async function addThreadMessage(request : FastifyRequest<AddThreadMessageParams>, reply : FastifyReply) {
    const thread = await Thread.findById(request.body.threadId);
    if (!thread) {
        reply.code(404).send({ error: 'Thread not found' });
        return;
    }
    // @ts-ignore
    const username = await UserService.getUserName(request.user.id);
    if (!username) {
        reply.code(401).send({ error: 'Unauthorized' });
        return;
    }
    try {
        const { content, respondsTo } = request.body;
        const threadId = request.body.threadId;
        const message = await ThreadService.addThreadMessage(threadId, username, content, respondsTo);
        reply.code(201).send({messageId: message._id});
    } catch (error : any) {
        reply.code(500).send({ error: 'Internal server error' });
    }
}


interface ToggleMessageReactionParams extends RouteGenericInterface {
    Body: {
        reactIcon: string,
        threadId: string,
        messageId: string
    }
}
async function toggleMessageReaction(request : FastifyRequest<ToggleMessageReactionParams>, reply : FastifyReply) {
    // @ts-ignore
    const username = await UserService.getUserName(request.user.id);
    if (!username) {
        reply.code(401).send({ error: 'Unauthorized' });
        return;
    }
    const { reactIcon, messageId, threadId } = request.body;
    try {
        const reaction = await ThreadService.toggleMessageReaction(threadId, messageId, username, reactIcon);
        reply.send({reaction : reaction});
    } catch (error) {
        console.error('Error adding reaction:', error);
        reply.code(500).send({ error: 'Internal server error' });
    }
}

async function searchThreads(request : FastifyRequest, reply : FastifyReply) {
    const threads = await ThreadService.searchThreads(request);
    reply.send(threads);
}


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

async function clearCollection(request : FastifyRequest, reply : FastifyReply) {
    try {
        await ThreadService.clearCollection();
        reply.send({ message: 'Threads collection cleared' });
    } catch (error : any) {
        reply.code(500).send({ error: error.message });
    }
}


interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request : FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request : FastifyRequest, reply: FastifyReply) => void;
}
export default async function threadRoutes(server: MyFastifyInstance) {
    server.get('/threads/:threadId', getThread);
    server.get('/threads/search', searchThreads);
    server.post('/threads/new', { preValidation: [server.authenticate] }, createThread);
    server.post('/threads/messages', { preValidation: [server.authenticate] }, addThreadMessage);
    server.post('/threads/messages/reactions', { preValidation: [server.authenticate] }, toggleMessageReaction);
    server.delete('/threads/clear', { preValidation: [server.adminAuthenticate] }, clearCollection);
}