import { FastifyReply, FastifyRequest } from "fastify";
import { AuthenticatedRequest, BookSearchQuery, MyFastifyInstance } from "../types";
import SearchService from "./search.service";
import { findNearestBookboxesSchema, searchBookboxesSchema, searchBooksSchema, searchIssuesSchema, searchMyManagedBookboxesSchema, searchThreadsSchema, searchTransactionHistorySchema, searchUsersSchema } from "./search.schemas";

async function searchBooks(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { q, cls, asc, limit, page } = request.query as { 
            q?: string; 
            cls?: string; 
            asc?: boolean; 
            limit?: number; 
            page?: number; 
        };
        const books = await SearchService.searchBooks(
            q,
            cls,
            asc,
            limit,
            page
        );
        reply.send({ books });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function searchBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { q, cls, asc, longitude, latitude, limit, page } = request.query as { 
            q?: string; 
            cls?: string; 
            asc?: boolean; 
            longitude?: number; 
            latitude?: number;
            limit?: number;
            page?: number;
        };
        const bookboxes = await SearchService.searchBookboxes(
            q, cls, asc, longitude, latitude, limit, page
        );
        reply.send({ bookboxes });
    } catch (error: unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(400).send({ error: message });
    }
}

async function findNearestBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { longitude, latitude, maxDistance, searchByBorough, limit, page } = request.query as { 
            longitude: number; 
            latitude: number; 
            maxDistance?: number;
            searchByBorough?: boolean; 
            limit?: number;
            page?: number;
        };
        const bookboxes = await SearchService.findNearestBookboxes(
            longitude, latitude, maxDistance, searchByBorough, limit, page
        );
        reply.send({ bookboxes });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message});
    }
}

async function searchThreads(request : FastifyRequest, reply : FastifyReply) {
    const { q, cls, asc, limit, page } = request.query as { 
        q?: string; 
        cls?: string; 
        asc?: boolean;
        limit?: number;
        page?: number;
    };
    const threads = await SearchService.searchThreads(q, cls, asc, limit, page);
    reply.send(threads);
}

async function searchMyManagedBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const username = (request as AuthenticatedRequest).user.username;
        const { q, cls, asc, limit, page } = request.query as { 
            q?: string; 
            cls?: string; 
            asc?: boolean; 
            limit?: number;
            page?: number;
        };
        const bookboxes = await SearchService.searchMyManagedBookboxes(
            username, q, cls, asc, limit, page
        );
        reply.send({ bookboxes });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function searchTransactionHistory(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { username, bookTitle, bookboxId, limit, page } = request.query as { 
            username?: string; 
            bookTitle?: string; 
            bookboxId?: string; 
            limit?: number; 
            page?: number;
        };
        const transactions = await SearchService.searchTransactionHistory(
            username, bookTitle, bookboxId, limit, page
        );
        reply.send({ transactions });
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({ error: message });
    }
}  

async function searchIssues(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { username, bookboxId, status, oldestFirst, limit, page } = request.query as { 
            username?: string; 
            bookboxId?: string; 
            status?: string; 
            oldestFirst?: boolean;
            limit?: number; 
            page?: number;
        };
        const issues = await SearchService.searchIssues(
            username, bookboxId, status, oldestFirst, limit, page
        );
        reply.send({ issues });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function searchUsers(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { q, limit, page } = request.query as { 
            q?: string; 
            limit?: number; 
            page?: number;
        };
        const users = await SearchService.searchUsers(q, limit, page);
        reply.send({ users });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
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
    server.get('/search/issues', { schema: searchIssuesSchema }, searchIssues); 
    server.get('/search/users', { 
        preValidation: [server.adminAuthenticate],
        schema: searchUsersSchema 
    }, searchUsers);
}