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

        const thread = new Thread(request.body);
        await thread.save();
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
        thread.messages.push(request.body);
        await thread.save();
        reply.send(thread);
    });
}