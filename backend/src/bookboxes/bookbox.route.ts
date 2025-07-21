import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookboxService from "./bookbox.service";
import {
    addBookToBookboxSchema,
    getBookFromBookBoxSchema,
    getBookboxSchema,
    followBookBoxSchema,
    unfollowBookBoxSchema,
} from "./bookbox.schemas";
import { BookAddData } from "../types/book.types";
import { AuthenticatedRequest } from "../types/common.types";

async function addBookToBookbox(request: FastifyRequest, reply: FastifyReply) {
    try { 
        const response = await BookboxService.addBook(request as AuthenticatedRequest & { body: BookAddData; params: { bookboxId: string } });
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function getBookFromBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.getBookFromBookBox(request as AuthenticatedRequest & { params: { bookId: string; bookboxId: string } });
        reply.send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

interface GetBookBoxParams extends RouteGenericInterface {
    Params: {
        bookboxId: string
    }
}
 
async function getBookbox(request: FastifyRequest<GetBookBoxParams>, reply: FastifyReply) {
    try {
        const response = await BookboxService.getBookBox(request.params.bookboxId);
        reply.send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(404).send({error: message});
    }
}



async function followBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.followBookBox(request as AuthenticatedRequest & { params: { bookboxId: string } });
        reply.code(200).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function unfollowBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.unfollowBookBox(request as AuthenticatedRequest & { params: { bookboxId: string } });
        reply.code(200).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}



interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    bookManipAuth: (request: FastifyRequest, reply: FastifyReply) => void;
}

export default async function bookBoxRoutes(server: MyFastifyInstance) {
    // Public routes
    server.get('/bookboxes/:bookboxId', { schema: getBookboxSchema }, getBookbox);

    
    // User routes (authenticated)
    server.post('/bookboxes/follow/:bookboxId', { preValidation: [server.authenticate], schema: followBookBoxSchema }, followBookBox);
    server.delete('/bookboxes/unfollow/:bookboxId', { preValidation: [server.authenticate], schema: unfollowBookBoxSchema }, unfollowBookBox);
    
    // Book manipulation routes (special token required)
    server.delete('/bookboxes/:bookboxId/books/:bookId', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: getBookFromBookBoxSchema }, getBookFromBookBox);
    server.post('/bookboxes/:bookboxId/books/add', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: addBookToBookboxSchema }, addBookToBookbox);
}
