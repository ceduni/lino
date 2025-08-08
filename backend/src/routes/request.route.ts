import { FastifyReply, FastifyRequest } from "fastify";
import { RequestService } from "../services";
import { 
    sendBookRequestSchema,
    deleteBookRequestSchema,
    getBookRequestsSchema,
    toggleSolvedStatusSchema
} from "../schemas";
import { AuthenticatedRequest, MyFastifyInstance } from "../types";

async function sendBookRequest(request: FastifyRequest, reply: FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id; // Extract user ID from JWT token
        const { title, customMessage } = request.body as {
            title: string;
            customMessage?: string;
        };
        const response = await RequestService.requestBookToUsers(userId, title, customMessage);
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function deleteBookRequest(request: FastifyRequest, reply: FastifyReply) {
    try {
        const id = (request as { params: { id: string } }).params.id;
        await RequestService.deleteBookRequest(id);
        reply.code(204).send({message: 'Book request deleted'});
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}
 
async function getBookRequests(request: FastifyRequest, reply: FastifyReply) {
    try {
        const username = (request as { query: { username?: string } }).query.username;
        const response = await RequestService.getBookRequests(username);
        reply.code(200).send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}

async function toggleSolvedStatus(request: FastifyRequest, reply: FastifyReply) {
    try {
        const id = (request as { params: { id: string } }).params.id;
        const response = await RequestService.toggleSolvedStatus(id);
        reply.code(200).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}


export default async function requestRoutes(server: MyFastifyInstance) {
    server.post('/books/request', { preValidation: [server.authenticate], schema: sendBookRequestSchema }, sendBookRequest);
    server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: deleteBookRequestSchema }, deleteBookRequest);
    server.get('/books/requests', { schema: getBookRequestsSchema }, getBookRequests);
    server.patch('/books/request/:id/solve', { preValidation: [server.authenticate], schema: toggleSolvedStatusSchema }, toggleSolvedStatus);
}
