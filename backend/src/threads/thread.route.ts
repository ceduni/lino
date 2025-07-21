import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from 'fastify';
import ThreadService from './thread.service';
import Thread from "./thread.model";
import {
    createThreadSchema,
    deleteThreadSchema,
    addMessageSchema,
    toggleReactionSchema,
    getThreadSchema
} from "./thread.schemas";
import { clearCollectionSchema } from "../users/user.schemas";
import {broadcastMessage} from "../index";
import { ThreadCreateData, MessageCreateData, ReactionData } from "../types/thread.types";
import { AuthenticatedRequest, MyFastifyInstance } from "../types/common.types";


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
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({ error: message });
    }
}


export default async function threadRoutes(server: MyFastifyInstance) {
    server.get('/threads/:threadId', { schema : getThreadSchema }, getThread);
    server.post('/threads/new', { preValidation: [server.authenticate], schema : createThreadSchema }, createThread);
    server.delete('/threads/:threadId', { preValidation: [server.authenticate], schema : deleteThreadSchema }, deleteThread);
    server.post('/threads/messages', { preValidation: [server.authenticate], schema : addMessageSchema }, addThreadMessage);
    server.post('/threads/messages/reactions', { preValidation: [server.authenticate], schema : toggleReactionSchema }, toggleMessageReaction);
    server.delete('/threads/clear', { preValidation: [server.superAdminAuthenticate], schema : clearCollectionSchema }, clearCollection);
}
