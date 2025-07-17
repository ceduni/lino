import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookService from "./book.service";
import { 
    getBookInfoFromISBNSchema,
    searchBooksSchema,
    getBookSchema
} from "./book.schemas";
import { bookSchema } from "../models.schemas";
import { BookSearchQuery } from "../types/book.types";


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
}
