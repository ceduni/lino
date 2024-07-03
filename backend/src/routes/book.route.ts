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
    try {
        const isbn = request.params.isbn;
        const book = await BookService.getBookInfoFromISBN(isbn);
        reply.send(book);
    } catch (error : any) {
        reply.code(404).send({error: error.message});
    }
}

async function searchBooks(request: FastifyRequest, reply: FastifyReply) {
    try {
        const books = await BookService.searchBooks(request);
        reply.send({books : books});
    } catch (error : any) {
        reply.code(404).send({error: error.message});
    }
}

async function sendAlert(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.alertUsers(request);
        reply.send(response);
    } catch (error : any) {
        reply.code(400).send({error: error.message});
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
    } catch (error : any) {
        reply.code(404).send({error: error.message});
    }
}

interface GetBookBoxParams extends RouteGenericInterface {
    Params: {
        bookboxId: string
    }
}
async function getBookbox(request: FastifyRequest<GetBookBoxParams>, reply: FastifyReply) {
    try {
        const response = await BookService.getBookBox(request.params.bookboxId);
        reply.send(response);
    } catch (error : any) {
        reply.code(404).send({error: error.message});
    }
}


async function addNewBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.addNewBookbox(request);
        reply.code(201).send(response);
    } catch (error : any) {
        reply.code(400).send({error: error.message});
    }
}


async function clearCollection(request: FastifyRequest, reply: FastifyReply) {
    try {
        await BookService.clearCollection();
        reply.send({message: 'Books cleared'});
    } catch (error : any) {
        reply.code(500).send({error: error.message});
    }
}

interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function bookRoutes(server: MyFastifyInstance) {
    server.get('/books/get/:id', getBook);
    server.get('/books/bookbox/:bookboxId', getBookbox);
    server.get('/books/:bookQRCode/:bookboxId', { preValidation: [server.optionalAuthenticate] }, getBookFromBookBox);
    server.get('/books/:isbn', { preValidation: [server.optionalAuthenticate] }, getBookInfoFromISBN);
    server.get('/books/search', searchBooks);
    server.post('/books/add', { preValidation: [server.optionalAuthenticate] }, addBookToBookbox);
    server.post('/books/alert', { preValidation: [server.authenticate] }, sendAlert);
    server.post('/books/bookbox/new', { preValidation: [server.adminAuthenticate] }, addNewBookbox);
    server.delete('/books/clear', { preValidation: [server.adminAuthenticate] }, clearCollection);
}