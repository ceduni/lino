import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { BookSearchQuery, MyFastifyInstance } from "../types";
import SearchService from "./search.service";
import { findNearestBookboxesSchema, searchBookboxesSchema, searchBooksSchema, searchMyManagedBookboxesSchema, searchThreadsSchema, searchTransactionHistorySchema } from "./search.schemas";

async function searchBooks(request: FastifyRequest, reply: FastifyReply) {
    try {
        const books = await SearchService.searchBooks(request as { query: BookSearchQuery });
        reply.send({books : books});
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function searchBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const bookboxes = await SearchService.searchBookboxes(request as { 
            query: { 
                q?: string; 
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

async function findNearestBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { longitude, latitude, maxDistance, searchByBorough } = request.query as 
        { 
            longitude: number; 
            latitude: number; 
            maxDistance?: number;
            searchByBorough?: boolean; 
        };
        const bookboxes = await SearchService.findNearestBookboxes(longitude, latitude, maxDistance, searchByBorough);
        reply.send({ bookboxes });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

async function searchThreads(request : FastifyRequest, reply : FastifyReply) {
    const threads = await SearchService.searchThreads(request as { query: { q?: string; cls?: string; asc?: boolean } });
    reply.send(threads);
}

async function searchMyManagedBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const bookboxes = await SearchService.searchMyManagedBookboxes(request);
        reply.send({ bookboxes });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function searchTransactionHistory(request: FastifyRequest, reply: FastifyReply) {
    try {
        const transactions = await SearchService.searchTransactionHistory(request as { query: { username?: string; bookTitle?: string; bookboxId?: string; limit?: number } });
        reply.send({transactions});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}  

export default async function searchRoutes(server: MyFastifyInstance) {
    server.get('/search/books', { schema: searchBooksSchema }, searchBooks);
    server.get('/search/bookboxes', { schema: searchBookboxesSchema }, searchBookboxes);
    server.get('/search/bookboxes/nearest', { schema: findNearestBookboxesSchema }, findNearestBookboxes);
    server.get('/search/threads', { schema : searchThreadsSchema }, searchThreads);
    server.get('/search/bookboxes/admin', { 
        preValidation: [server.adminAuthenticate],
        schema: searchMyManagedBookboxesSchema
    }, searchMyManagedBookboxes);
    server.get('/search/transactions', { schema: searchTransactionHistorySchema }, searchTransactionHistory);

}