import {FastifyInstance, FastifyReply, FastifyRequest} from "fastify";
import RequestService from "../services/request.service";
import { 
    sendBookRequestSchema,
    deleteBookRequestSchema,
    getBookRequestsSchema
} from "../schemas/request.schemas";
import { AuthenticatedRequest } from "../types/common.types";

async function sendBookRequest(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await RequestService.requestBookToUsers(request as AuthenticatedRequest & { 
            body: { title: string; customMessage?: string }; 
            query: { latitude?: number; longitude?: number } 
        });
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function deleteBookRequest(request: FastifyRequest, reply: FastifyReply) {
    try {
        await RequestService.deleteBookRequest(request as { params: { id: string } });
        reply.code(204).send({message: 'Book request deleted'});
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}
 
async function getBookRequests(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await RequestService.getBookRequests(request as { query: { username?: string } });
        reply.code(200).send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}

interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}

export default async function requestRoutes(server: MyFastifyInstance) {
    server.post('/books/request', { preValidation: [server.authenticate], schema: sendBookRequestSchema }, sendBookRequest);
    server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: deleteBookRequestSchema }, deleteBookRequest);
    server.get('/books/requests', { schema: getBookRequestsSchema }, getBookRequests);
}
