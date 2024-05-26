import { FastifyInstance } from "fastify";
import BookBox from "../models/bookbox.model";
import bookService from "../services/book.service";
import User from "../models/user.model";
import UserService from "../services/user.service";

export default async function bookRoutes(server: FastifyInstance) {
    // API Endpoint: Add Book to Bookbox
    // @ts-ignore
    server.post('/book/:isbn/:bookboxId/:action', { preValidation: [server.authenticate] }, async (request, reply) => {
        const { isbn, bookboxId, action } = request.params as { isbn: string; bookboxId: string; action: string };

        try {
            const book = await bookService.fetchOrCreateBook(isbn);

            let bookbox = await BookBox.findById(bookboxId);
            if (!bookbox) {
                reply.code(404).send({ error: 'Bookbox not found' });
                return;
            }

            if (request.user) {
                // @ts-ignore
                const userId = request.user.id;
                let user = await User.findById(userId);
                if (user) {
                    // @ts-ignore
                    user.ecologicalImpact.carbonSavings += 27.71;
                    // @ts-ignore
                    user.ecologicalImpact.savedWater += 2000;
                    // @ts-ignore
                    user.ecologicalImpact.savedTrees += 0.005;
                    await user.save();
                }
            }

            if (action === 'given') {
                book.given_history.push({ timestamp: new Date() });
                bookbox.books.push(isbn);
            } else if (action === 'taken') {
                book.taken_history.push({ timestamp: new Date() });
                bookbox.books = bookbox.books.filter((bookId) => bookId !== isbn);
            } else {
                reply.code(400).send({ error: 'Invalid action' });
                return;
            }

            await book.save();
            await bookbox.save();
            reply.send({ message: 'Success' });
        } catch (error) {
            console.error(`Error handling book ${action} action:`, error);
            reply.code(500).send({ error: 'Internal server error: ' + error });
        }
    });


    // API Endpoint: Get Book Details
    // @ts-ignore
    server.get('/book/:isbn', async (request, reply) => {
        // @ts-ignore
        const isbn = request.params.isbn;

        try {
            // Fetch/create the book if needed
            const book = await bookService.fetchOrCreateBook(isbn);
            // Send the book information to the user
            reply.send(book);
        } catch (error) {
            // Handle errors (e.g., book not found, server issue)
            // @ts-ignore
            if (error.message === 'Book not found') {
                reply.code(404).send({ error: 'Book not found' });
            } else {
                console.error('Error fetching or saving book data:', error);
                reply.code(500).send({ error: 'Internal server error' });
            }
        }
    });


    // API Endpoint: Add Book to Favorites (protected route)
    // @ts-ignore
    server.post('/books/favorites', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { isbn } = request.body;
            const user = await UserService.addToFavorites(userId, isbn);
            reply.send(user);
        } catch (error) {
            console.error('Error adding book to favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Remove Book from Favorites (protected route)
    // @ts-ignore
    server.delete('/books/favorites', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { isbn } = request.body;
            const user = await UserService.removeFromFavorites(userId, isbn);
            reply.send(user);
        } catch (error) {
            console.error('Error removing book from favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

}
