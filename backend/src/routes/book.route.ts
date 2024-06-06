import { FastifyInstance } from "fastify";
import Book from "../models/book.model";
import BookService from "../services/book.service";

export default async function bookRoutes(server: FastifyInstance) {
    // API Endpoint: Add new book to Bookbox
    // @ts-ignore
    server.post('/book/:bookboxId/add', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const bookboxId = request.params.bookboxId;
            const bookId = await BookService.addNewBook(request, bookboxId);
            if (bookId) {
                reply.send({ bookId });
            } else {
                reply.code(500).send({ error: 'Internal server error' });
            }
        } catch (error) {
            console.error('Error adding book:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Add an already registered book to Bookbox
    // @ts-ignore
    server.post('/book/:bookId/:bookboxId/add', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const bookId = request.params.bookId;
            // @ts-ignore
            const bookboxId = request.params.bookboxId;
            const book = await BookService.addExistingBook(bookId, request, bookboxId);
            reply.send({ book });
        } catch (error) {
            console.error('Error adding book:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });


    // API Endpoint : Get a book from a bookbox
    // @ts-ignore
    server.post('/book/:bookId/:bookboxId/get', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const bookId = request.params.bookId;
            // @ts-ignore
            const bookboxId = request.params.bookboxId;
            const book = await BookService.getBookFromBookBox(bookId, request, bookboxId);
            reply.send({ book });
        } catch (error) {
            console.error('Error getting book:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });


    // @ts-ignore
    // API Endpoint: Get Books by ISBN
    server.get('/books/:isbn', async (request, reply) => {
        try {
            // @ts-ignore
            const books = await Book.find({ isbn: request.params.isbn });
            reply.send(books);
        } catch (error) {
            console.error('Error getting books:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });


    // API Endpoint: Research all books of the database (with optional genre query)
    // @ts-ignore
    server.get('/books', async (request, reply) => {
        try {
            // @ts-ignore
            const genre = request.query.genre;
            let books;
            if (genre) {
                books = await Book.find({ categories: genre });
            } else {
                books = await Book.find();
            }
            reply.send(books);
        } catch (error) {
            console.error('Error getting books:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

}
