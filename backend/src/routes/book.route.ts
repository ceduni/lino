import { FastifyInstance } from "fastify";
import BookBox from "../models/bookbox.model";
import bookService from "../services/book.service";
import User from "../models/user.model";
import UserService from "../services/user.service";
import Book from "../models/book.model";
import * as http from "node:http";
import mongoose from "mongoose";
import BookModel from "../models/book.model";
import BookService from "../services/book.service";

export default async function bookRoutes(server: FastifyInstance) {
    // API Endpoint: Add Book to Bookbox
    // @ts-ignore
    server.post('/book/:isbn/:bookboxId/add', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        const { isbn, bookboxId } = request.params as { isbn: string; bookboxId: string };

        try {
            // Fetch or create the book
            const book = await bookService.fetchOrCreateBook(new mongoose.Types.ObjectId(''), isbn);

            // Fetch the bookbox
            let bookbox = await BookBox.findById(bookboxId);
            if (!bookbox) {
                reply.code(404).send({ error: 'Bookbox not found' });
                return;
            }

            await BookService.updateUserEcoImpact(request, book._id.toString());

            if (request.user) {
                // @ts-ignore
                const userId = request.user.id;
                book.given_history.push({user_id: userId, timestamp: new Date()});
            } else {
                book.given_history.push({user_id: 'guest', timestamp: new Date()});
            }
            const books : any = Book.find({isbn: isbn});
            for (let i = 0; i < books.length; i++) {
                // Update the date_last_action field for all books with the same ISBN
                // to indicate that this book has been looked at recently
                books[i].date_last_action = new Date();
            }

            await book.save();
            await bookbox.save();
            reply.send({ message: 'Success' });
        } catch (error) {
            console.error(`Error handling book addition:`, error);
            reply.code(500).send({ error: 'Internal server error: ' + error });
        }
    });

    // API Endpoint: Retire a book from the bookbox
    // @ts-ignore
    server.post('/book/:bookId/:bookboxId/retire', { preValidation: [server.optionalAuthenticate] }, async (request, reply) => {
        const {bookId, bookboxId} = request.params as {bookId: string, bookboxId: string};
        try {
            const book = await Book.findById(bookId);
            if (!book) {
                reply.code(404).send({ error: 'Book not found' });
                return;
            }
            const bookbox = await BookBox.findById(bookboxId);
            if (!bookbox) {
                reply.code(404).send({ error: 'Bookbox not found' });
                return;
            }

            // if book is not in the bookbox, return an error
            if (!bookbox.books.includes(new mongoose.Types.ObjectId(bookId))) {
                reply.code(404).send({ error: 'Book not in bookbox' });
                return;
            }
            // remove the book from the bookbox
            bookbox.books = bookbox.books.filter(b => b.toString() !== bookId);
            await bookbox.save();

            // if user is authenticated, update the user's ecological impact
            await BookService.updateUserEcoImpact(request, bookId);


        } catch (error) {
            console.error(`Error retiring book:`, error);
            reply.code(500).send({ error: 'Internal server error: ' + error });
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


    // API Endpoint: Add Book to Favorites (protected route)
    // @ts-ignore
    server.post('/books/favorites/:isbn', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { isbn } = request.params;
            const user = await UserService.addToFavorites(userId, isbn);
            reply.send(user);
        } catch (error) {
            console.error('Error adding book to favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Remove Book from Favorites (protected route)
    // @ts-ignore
    server.delete('/books/favorites/:isbn', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { isbn } = request.params;
            const user = await UserService.removeFromFavorites(userId, isbn);
            reply.send(user);
        } catch (error) {
            console.error('Error removing book from favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

}
