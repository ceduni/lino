import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookService from "../services/book.service";



async function addBookToBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.addBook(request);
        reply.send(response);
    } catch (error : any) {
        reply.code(400).send({error: error.message});
    }
}


interface GetBookParams extends RouteGenericInterface {
    Params: {
        bookQRCode: string,
        bookboxId: string
    }
}
async function getBookFromBookBox(request: FastifyRequest<GetBookParams>, reply: FastifyReply) {
    const qrCode = request.params.bookQRCode;
    const bookboxId = request.params.bookboxId;
    try {
        const response = await BookService.getBookFromBookBox(qrCode, request, bookboxId);
        reply.send(response);
    } catch (error : any) {
        reply.code(400).send({error: error.message});
    }
}

interface Params extends RouteGenericInterface {
    Params: {
        isbn: string
    }
}
async function getBookInfoFromISBN(request: FastifyRequest<Params>, reply: FastifyReply) {
    const isbn = request.params.isbn;
    const book = await BookService.getBookInfoFromISBN(isbn);
    reply.send(book);
}

async function searchBooks(request: FastifyRequest, reply: FastifyReply) {
    const books = await BookService.searchBooks(request);
    reply.send({books : books});
}


interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
}
export default async function bookRoutes(server: MyFastifyInstance) {
    server.post('/books/add', { preValidation: [server.optionalAuthenticate] }, addBookToBookbox);
    server.get('/books/:bookQRCode/:bookboxId', { preValidation: [server.optionalAuthenticate] }, getBookFromBookBox);
    server.get('/books/:isbn', { preValidation: [server.optionalAuthenticate] }, getBookInfoFromISBN);
    server.get('/books/search', searchBooks);
    server.delete('/books/clear', async (request, reply) => {
        await BookService.clearCollection();
        reply.send({message: 'Books cleared'});
    });
}