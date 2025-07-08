import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookService from "../services/book.service";
import { 
    getBookInfoFromISBNSchema,
    searchBooksSchema,
    sendBookRequestSchema,
    deleteBookRequestSchema,
    getBookSchema,
    getBookRequestsSchema,
    getTransactionHistorySchema
} from "../schemas/book.schemas";
import { bookSchema } from "../schemas/models.schemas";
import { BookSearchQuery } from "../types/book.types";
import { AuthenticatedRequest } from "../types/common.types";


interface Params extends RouteGenericInterface { 
    Params: {
        isbn: string
    }
}
async function getBookInfoFromISBN(request: FastifyRequest<Params>, reply: FastifyReply) {
    try {
        const book = await BookService.getBookInfoFromISBN(request as { params: { isbn: string } });
        reply.send(book);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}


async function searchBooks(request: FastifyRequest, reply: FastifyReply) {
    try {
        const books = await BookService.searchBooks(request as { query: BookSearchQuery });
        reply.send({books : books});
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}


async function sendBookRequest(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.requestBookToUsers(request as AuthenticatedRequest & { 
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
        await BookService.deleteBookRequest(request as { params: { id: string } });
        reply.code(204).send({message: 'Book request deleted'});
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

interface GetUniqueBookParams extends RouteGenericInterface {
    Params: {
        id: string
    }
}
async function getBook(request: FastifyRequest<GetUniqueBookParams>, reply: FastifyReply) {
    try {
        const book = await BookService.getBook(request.params.id);
        reply.send(book);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(404).send({error: message});
    }
}

async function getBookRequests(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.getBookRequests(request as { query: { username?: string } });
        reply.code(200).send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}

async function getTransactionHistory(request: FastifyRequest, reply: FastifyReply) {
    try {
        const transactions = await BookService.getTransactionHistory(request as { query: { username?: string; bookTitle?: string; bookboxId?: string; limit?: number } });
        reply.send({transactions});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}

interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    bookManipAuth: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function bookRoutes(server: MyFastifyInstance) {
    server.get('/books/:id', { schema : getBookSchema }, getBook);
    server.get('/books/info-from-isbn/:isbn', { preValidation: [server.optionalAuthenticate], schema: getBookInfoFromISBNSchema }, getBookInfoFromISBN);
    server.get('/books/search', { schema: searchBooksSchema }, searchBooks);
    server.post('/books/request', { preValidation: [server.authenticate], schema: sendBookRequestSchema }, sendBookRequest);
    server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: deleteBookRequestSchema }, deleteBookRequest);
    server.get('/books/requests', { schema: getBookRequestsSchema }, getBookRequests);
    server.get('/books/transactions', { schema: getTransactionHistorySchema }, getTransactionHistory);
}
