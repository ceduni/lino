import { FastifyReply, FastifyRequest } from "fastify";
import BookboxService from "./bookbox.service";
import {
    addBookToBookboxSchema,
    getBookFromBookBoxSchema,
    getBookboxSchema,
    followBookBoxSchema,
    unfollowBookBoxSchema,
} from "./bookbox.schemas";
import { BookAddData } from "../types/book.types";
import { AuthenticatedRequest, MyFastifyInstance } from "../types/common.types";

async function addBookToBookbox(request: FastifyRequest, reply: FastifyReply) {
    try { 
        const user = (request as AuthenticatedRequest).user;
        const userId = user?.id || undefined;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        const { title, isbn, authors, description, coverImage, publisher, parutionYear, pages, categories } = request.body as BookAddData;
        const response = await BookboxService.addBook({
            bookboxId, 
            title, 
            isbn, 
            authors, 
            description, 
            coverImage, 
            publisher, 
            parutionYear, 
            pages, 
            categories, 
            userId
        });
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function getBookFromBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const user = (request as AuthenticatedRequest).user;
        const userId = user?.id || undefined;
        const { bookId, bookboxId } = (request as { params: { bookId: string; bookboxId: string } }).params;
        const response = await BookboxService.getBookFromBookBox(bookboxId, bookId, userId);
        reply.send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}


async function getBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        const response = await BookboxService.getBookBox(bookboxId);
        reply.send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(404).send({error: message});
    }
}



async function followBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const user = (request as AuthenticatedRequest).user;
        const userId = user.id;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        const response = await BookboxService.followBookBox(bookboxId, userId);
        reply.code(200).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function unfollowBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const user = (request as AuthenticatedRequest).user;
        const userId = user.id;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        const response = await BookboxService.unfollowBookBox(bookboxId, userId);
        reply.code(200).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
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
