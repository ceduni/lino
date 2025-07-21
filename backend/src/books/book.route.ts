import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookService from "./book.service";
import { 
    getBookInfoFromISBNSchema,
    getBookSchema
} from "./book.schemas";
import { MyFastifyInstance } from "../types";


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


export default async function bookRoutes(server: MyFastifyInstance) {
    server.get('/books/:id', { schema : getBookSchema }, getBook);
    server.get('/books/info-from-isbn/:isbn', { preValidation: [server.optionalAuthenticate], schema: getBookInfoFromISBNSchema }, getBookInfoFromISBN);
}
