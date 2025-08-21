import { FastifyReply, FastifyRequest } from "fastify";
import { BookService } from "../services";
import { 
    getBookInfoFromISBNSchema,
    getBookSchema,
    getBookStatsSchema
} from "../schemas";
import { MyFastifyInstance } from "../types";


async function getBookInfoFromISBN(request: FastifyRequest, reply: FastifyReply) {
    try {
        const isbn = (request as { params: { isbn: string } }).params.isbn;
        const book = await BookService.getBookInfoFromISBN(isbn);
        reply.send(book);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
} 


async function getBook(request: FastifyRequest, reply: FastifyReply) {
    try {
        const id = (request as { params: { id: string } }).params.id;
        const book = await BookService.getBook(id);
        reply.send(book);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(404).send({error: message});
    }
}

async function getBookStats(request: FastifyRequest, reply: FastifyReply) {
    try {
        const isbn = (request as { params: { isbn: string } }).params.isbn;
        const stats = await BookService.getBookStats(isbn);
        reply.send(stats);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(404).send({error: message});
    }
}


export default async function bookRoutes(server: MyFastifyInstance) {
    server.get('/books/:id', { schema : getBookSchema }, getBook);
    server.get('/books/info-from-isbn/:isbn', { preValidation: [server.optionalAuthenticate], schema: getBookInfoFromISBNSchema }, getBookInfoFromISBN);
    server.get('/books/stats/:isbn', { schema: getBookStatsSchema }, getBookStats);
}
