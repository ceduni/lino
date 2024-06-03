import { FastifyInstance } from 'fastify';
import Thread from '../models/thread.model';

export default async function threadRoutes(server: FastifyInstance) {
    server.get('/threads/:book_id', async (request, reply) => {
        // @ts-ignore
        const threads = await Thread.find({ book_id: request.params.book_id });
        reply.send(threads);
    });

    // @ts-ignore
    server.post('/threads', { preHandler: server.authenticate }, async (request, reply) => {
        // @ts-ignore
        request.body.user_id = request.user.id;
        const thread = new Thread(request.body);
        try {
            await thread.save();
            reply.send(thread);
        } catch (error) {
            // @ts-ignore
            reply.status(500).send({ error: error.toString() });
        }
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
        const message = { content: request.body.content, user_id: request.user.id };
        // @ts-ignore
        thread.messages.push(message);
        await thread.save();
        reply.send(thread);
    });
}