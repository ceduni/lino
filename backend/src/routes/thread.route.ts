import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from 'fastify';
import ThreadService from '../services/thread.service';
import UserService from "../services/user.service";
import Thread from "../models/thread.model";


interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request : FastifyRequest, reply: FastifyReply) => void;
}
export default async function threadRoutes(server: MyFastifyInstance) {
    server.post('/threads/new', { preValidation: [server.authenticate] }, createThread);
    server.post('/threads/messages', { preValidation: [server.authenticate] }, addThreadMessage);
    server.post('/threads/messages/reactions', { preValidation: [server.authenticate] }, toggleMessageReaction);
    server.get('/threads/search', searchThreads);
    server.delete('/threads/clear', clearCollection);
}

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
    reply.send({threadId: thread._id});
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
    const { content, respondsTo } = request.body;
    const threadId = request.body.threadId;
    const message = await ThreadService.addThreadMessage(threadId, username, content, respondsTo);
    reply.send({messageId: message._id});
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

async function clearCollection(request : FastifyRequest, reply : FastifyReply) {
    await ThreadService.clearCollection();
    reply.send({ message: 'Threads collection cleared' });
}