import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookService from "../services/book.service";
import BookBox from "../models/bookbox.model";



async function addBookToBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.addBook(request);
        reply.code(201).send(response);
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

async function sendAlert(request: FastifyRequest, reply: FastifyReply) {
    const response = await BookService.alertUsers(request);
    reply.send(response);
}

interface GetUniqueBookParams extends RouteGenericInterface {
    Params: {
        id: string
    }
}
async function getBook(request: FastifyRequest<GetUniqueBookParams>, reply: FastifyReply) {
    const book = await BookService.getBook(request.params.id);
    reply.send(book);
}

interface GetBookBoxParams extends RouteGenericInterface {
    Params: {
        bookboxId: string
    }
}
async function getBookbox(request: FastifyRequest<GetBookBoxParams>, reply: FastifyReply) {
    const response = await BookBox.findById(request.params.bookboxId);
    reply.send(response);
}

async function addNewBookbox(request: FastifyRequest, reply: FastifyReply) {
    const response = await BookService.addNewBookbox(request);
    reply.code(201).send(response);
}

async function clearCollection(request: FastifyRequest, reply: FastifyReply) {
    await BookService.clearCollection();
    reply.send({message: 'Books cleared'});

}

interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
    authenticate: (request: FastifyRequest) => void;
}
export default async function bookRoutes(server: MyFastifyInstance) {
    server.post('/books/add', { preValidation: [server.optionalAuthenticate] }, addBookToBookbox);
    server.get('/books/:bookQRCode/:bookboxId', { preValidation: [server.optionalAuthenticate] }, getBookFromBookBox);
    server.get('/books/:isbn', { preValidation: [server.optionalAuthenticate] }, getBookInfoFromISBN);
    server.get('/books/search', searchBooks);
    server.post('/books/alert', { preValidation: [server.authenticate] }, sendAlert);
    server.get('/books/get/:id', getBook);
    server.get('/books/bookbox/:bookboxId', getBookbox);
    server.post('/books/bookbox/new', addNewBookbox);
    server.delete('/books/clear', clearCollection);
}