import { FastifyReply, FastifyRequest } from "fastify";
import { RequestService } from "../services";
import { 
    sendBookRequestSchema,
    deleteBookRequestSchema,
    toggleSolvedStatusSchema,
    toggleUpvoteSchema
} from "../schemas";
import { AuthenticatedRequest, MyFastifyInstance } from "../types";

async function sendBookRequest(request: FastifyRequest, reply: FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id; // Extract user ID from JWT token
        const { title, customMessage, bookboxIds } = request.body as {
            title: string;
            customMessage?: string;
            bookboxIds?: string[];
        };
        const response = await RequestService.requestBookToUsers(userId, title, bookboxIds, customMessage);
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

async function toggleUpvote(request: FastifyRequest, reply: FastifyReply) {
    try {
        const requestId = (request as { params: { id: string } }).params.id;
        const userId = (request as AuthenticatedRequest).user.id; // Extract user ID from JWT token
        
        const response = await RequestService.toggleUpvote(requestId, userId);
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
    server.patch('/books/request/:id/solve', { preValidation: [server.authenticate], schema: toggleSolvedStatusSchema }, toggleSolvedStatus);
    server.patch('/books/request/:id/upvote', { preValidation: [server.authenticate], schema: toggleUpvoteSchema }, toggleUpvote);
}
