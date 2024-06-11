import {FastifyInstance, FastifyReply, FastifyRequest} from "fastify";
import Book from "../models/book.model";
import BookService from "../services/book.service";
import BookBox from "../models/bookbox.model";
import * as http from "node:http";

export default async function bookRoutes(server: FastifyInstance) {
    // API Endpoint: Add new book to Bookbox
    // @ts-ignore
    server.post('/book/:bookboxId', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const bookboxId = request.params.bookboxId;
            const bookId = await BookService.addNewBook(request, bookboxId);
            const bookBox = await BookBox.findById(bookboxId);
            if (bookId) {
                reply.send({ bookId: bookId, books : bookBox?.books });
            } else {
                reply.code(500).send({ error: 'Internal server error' });
            }
        } catch (error) {
            console.error('Error adding book:', error);
            // @ts-ignore
            reply.code(400).send({ error: error.message });
        }
    });

    // API Endpoint: Add an already registered book to Bookbox
    // @ts-ignore
    server.post('/book/:bookId/:bookboxId', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const bookId = request.params.bookId;
            // @ts-ignore
            const bookboxId = request.params.bookboxId;
            const book = await BookService.addExistingBook(bookId, request, bookboxId);
            const bookBox = await BookBox.findById(bookboxId);
            if (bookId) {
                reply.send({ book: book, books : bookBox?.books });
            } else {
                reply.code(500).send({ error: 'Internal server error' });
            }
        } catch (error) {
            console.error('Error adding book:', error);
            // @ts-ignore
            reply.code(400).send({ error: error.message });
        }
    });


    // API Endpoint : Get a book from a bookbox
    // @ts-ignore
    server.get('/book/:bookId/:bookboxId', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const bookId = request.params.bookId;
            // @ts-ignore
            const bookboxId = request.params.bookboxId;
            const book = await BookService.getBookFromBookBox(bookId, request, bookboxId);
            const bookbox = await BookBox.findById(bookboxId);
            // @ts-ignore
            reply.send({ book : book, books : bookbox.books });
        } catch (error) {
            console.error('Error getting book:', error);
            // @ts-ignore
            reply.code(400).send({ error: error.message });
        }
    });


    // API Endpoint : Try to get infos about a book from its ISBN
    // @ts-ignore
    server.get('/book/:isbn', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const isbn = request.params.isbn;
            const book = await BookService.getBookInfoFromISBN(isbn);
            // @ts-ignore
            reply.send(book);
        } catch (error) {
            console.error('Error getting book:', error);
            // @ts-ignore
            reply.code(400).send({ error: error.message });
        }
    });



    // API Endpoint: Research all books of the database (with quite a lot of filter queries)
    // @ts-ignore
    server.get('/books/search', async (request, reply) => {
        try {
            const books = await BookService.searchBooks(request);
            reply.send({books : books});
        } catch (error) {
            console.error('Error getting books:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Clear collection
    // @ts-ignore
    server.delete('/books/clear', async (request, reply) => {
        try {
            await BookService.clearCollection();
            reply.send({ message: 'Collection cleared' });
        } catch (error) {
            console.error('Error clearing collection:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
