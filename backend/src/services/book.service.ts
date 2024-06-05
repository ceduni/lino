import axios from 'axios';
import Book from "../models/book.model";
import mongoose from "mongoose";
import User from "../models/user.model";

const bookService = {
    // Helper function to fetch or create a book
    // This function tries to find a book in the database. If not found, it gets info from Google Books API and creates a new book entry.
    async fetchOrCreateBook(id : mongoose.Types.ObjectId, isbn: string) {
        let book = await Book.findOne(id); // Look for the book by its ID
        if (!book) { // If book doesn't exist
            // Make an API call to Google Books for the book details with the given ISBN
            const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}`);
            const data = response.data;

            if (data.totalItems === 0) { // If Google Books doesn't find it either
                throw new Error('Book not found');
            }

            const volumeInfo = data.items[0].volumeInfo; // Get the book details

            // Create a new book document based on the API data (will create a unique _id)
            book = new Book({
                isbn: isbn,
                title: volumeInfo.title,
                authors: volumeInfo.authors,
                description: volumeInfo.description,
                coverImage: volumeInfo.imageLinks?.thumbnail,
                publisher: volumeInfo.publisher,
                categories: volumeInfo.categories,
                taken_history: [],
                given_history: []
            });
            await book.save(); // Save the new book to the database
        }
        return book; // Return the book (either found or newly created)
    },

    async updateUserEcoImpact(request: any, bookId: string) {
        // if user is authenticated, update the user's ecological impact
        if (request.user) {
            // @ts-ignore
            const userId = request.user.id;
            let user = await User.findById(userId);
            if (user) {

                if (!user.trackedBooks.includes(new mongoose.Types.ObjectId(bookId))) {
                    // add the book to the user's tracked books if it's not already there
                    user.trackedBooks.push(new mongoose.Types.ObjectId(bookId));

                    // the user can't gain ecological impact from the same book twice
                    // @ts-ignore
                    user.ecologicalImpact.carbonSavings += 27.71;
                    // @ts-ignore
                    user.ecologicalImpact.savedWater += 2000;
                    // @ts-ignore
                    user.ecologicalImpact.savedTrees += 0.005;
                }
                await user.save();
            }
        }
    },
};

export default bookService;