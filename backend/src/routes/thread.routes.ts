import { FastifyInstance } from 'fastify';
import Thread from '../models/thread.model';
import ThreadService from '../services/thread.service';

export default async function threadRoutes(server: FastifyInstance) {
    server.get('/threads/:book_id', async (request, reply) => {
        // @ts-ignore
        const threads = await Thread.find({ book_id: request.params.book_id });
        reply.send(threads);
    });

    // @ts-ignore
    server.post('/threads', { preHandler: server.authenticate }, async (request, reply) => {
        // @ts-ignore
        const userId = request.user.id;
        if (!userId) {
            reply.code(401).send({ error: 'Unauthorized' });
            return;
        }
        // @ts-ignore
        const { book_id, title } = request.body;
        const thread = await ThreadService.createThread(book_id, userId, title);
        reply.send(thread);

    });

    // @ts-ignore
    server.post('/threads/:thread_id/messages', { preHandler: server.authenticate }, async (request, reply) => {
        // @ts-ignore
        const thread = await Thread.findById(request.params.thread_id);
        if (!thread) {
            reply.code(404).send({ error: 'Thread not found' });
            return;
        }
        // @ts-ignore
        const userId = request.user.id;
        if (!userId) {
            reply.code(401).send({ error: 'Unauthorized' });
            return;
        }
        // @ts-ignore
        const { content, responds_to } = request.body;
        // @ts-ignore
        const threadId = request.params.thread_id;
        const updatedThread = await ThreadService.addThreadMessage(threadId, userId, content, responds_to);
        reply.send(updatedThread);
    });

    // API Endpoint: Toggle Reaction to Message
    // @ts-ignore
    server.post('/threads/:thread_id/messages/:message_id/reactions', { preHandler: server.authenticate }, async (request, reply) => {
        // @ts-ignore
        const userId = request.user.id;
        if (!userId) {
            reply.code(401).send({ error: 'Unauthorized' });
            return;
        }
        // @ts-ignore
        const { react_icon } = request.body;
        // @ts-ignore
        const { thread_id, message_id } = request.params;
        try {
            await ThreadService.toggleMessageReaction(thread_id, message_id, userId, react_icon);
            reply.send({ message: 'Success' });
        } catch (error) {
            console.error('Error adding reaction:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}