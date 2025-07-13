import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookboxService from "../services/bookbox.service";
import {
    addBookToBookboxSchema,
    getBookFromBookBoxSchema,
    getBookboxSchema,
    addNewBookboxSchema,
    searchBookboxesSchema,
    deleteBookBoxSchema,
    updateBookBoxSchema
} from "../schemas/bookbox.schemas";
import { clearCollectionSchema } from "../schemas/user.schemas";
import { bookSchema } from "../schemas/models.schemas";
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

async function addNewBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.addNewBookbox(request as { 
            body: { 
                name: string; 
                image?: string; 
                longitude: number; 
                latitude: number; 
                infoText?: string; 
            } 
        });
        reply.code(201).send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(400).send({error: message});
    }
}

async function searchBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const bookboxes = await BookboxService.searchBookboxes(request as { 
            query: { 
                kw?: string; 
                cls?: string; 
                asc?: boolean; 
                longitude?: number; 
                latitude?: number; 
            } 
        });
        reply.send({bookboxes : bookboxes});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(400).send({error: message});
    }
}

async function deleteBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.deleteBookBox(request as AuthenticatedRequest & { params: { bookboxId: string } });
        reply.code(204).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';  
        reply.code(statusCode).send({error: message});
    }
}

async function updateBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.updateBookBox(request as AuthenticatedRequest & { body: { 
            name?: string;
            image?: string;
            longitude?: number; 
            latitude?: number;
            infoText?: string;
        }; params: { bookboxId: string } });
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
    server.get('/bookboxes/:bookboxId', { schema: getBookboxSchema }, getBookbox);
    server.get('/bookboxes/search', { schema: searchBookboxesSchema }, searchBookboxes);
    server.post('/bookboxes/new', { preValidation: [server.adminAuthenticate], schema: addNewBookboxSchema }, addNewBookbox);
    server.delete('/bookboxes/:bookboxId/books/:bookId', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: getBookFromBookBoxSchema }, getBookFromBookBox);
    server.post('/bookboxes/:bookboxId/books/add', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: addBookToBookboxSchema }, addBookToBookbox);
    server.delete('/bookboxes/:bookboxId', { preValidation: [server.adminAuthenticate], schema: deleteBookBoxSchema }, deleteBookBox);
    server.put('/bookboxes/:bookboxId', { preValidation: [server.adminAuthenticate], schema: updateBookBoxSchema }, updateBookBox);
}
