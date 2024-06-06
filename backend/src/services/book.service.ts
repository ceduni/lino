import axios from 'axios';
import Book from "../models/book.model";
import mongoose from "mongoose";
import User from "../models/user.model";
import BookBox from "../models/bookbox.model";

const bookService = {
    // Helper function to fetch or create a book
    // This function tries to find a book in the database. If not found, it gets info from Google Books API and creates a new book entry.
    async addNewBook(request: any, bookboxId: string) {
        let book = new Book({
            isbn: request.body.isbn,
            title: request.body.title,
            authors: request.body.authors,
            description: request.body.description,
            coverImage: request.body.coverImage,
            publisher: request.body.publisher,
            parutionYear: request.body.parutionYear,
            pages: request.body.pages,
            categories: request.body.categories,
        });
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        bookBox.books.push(book._id);
        await this.updateBooks(book, request, true);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book._id.toString());
        return book._id;
    },

    async addExistingBook(id: string, request: any, bookboxId: string) {
        let book = await Book.findById(id);
        if (!book) {
            throw new Error('Book not found');
        }
        await this.updateBooks(book, request, true);
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        bookBox.books.push(book._id);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book._id.toString());
        return book;
    },

    async getBookFromBookBox(id: string, request: any, bookboxId: string) {
        let book = await Book.findById(id);
        if (!book) {
            throw new Error('Book not found');
        }
        await this.updateBooks(book, request, false);
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        if (bookBox.books.includes(book._id)) {
            bookBox.books.splice(bookBox.books.indexOf(book._id), 1);
        } else {
            throw new Error('Book not found in bookbox');
        }
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book._id.toString());
        return book;
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

    async updateBooks(book: any, request: any, given: boolean) {
        if (request.user) {
            // @ts-ignore
            const userId = request.user.id;
            if (given) {
                book.given_history.push({user_id: userId, timestamp: new Date()});
            } else {
                book.taken_history.push({user_id: userId, timestamp: new Date()});
            }
        } else {
            if (given) {
                book.given_history.push({user_id: "guest", timestamp: new Date()});
            } else {
                book.taken_history.push({user_id: "guest", timestamp: new Date()});
            }
        }
        const books : any = await Book.find({isbn: book.isbn});
        for (let i = 0; i < books.length; i++) {
            // Update the date_last_action field for all books with the same ISBN
            // to indicate that this book has been looked at recently
            books[i].date_last_action = new Date();
        }
    },

    async getBookInfoFromISBN(isbn: string) {
        const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}`);
        if (response.data.totalItems === 0) {
            throw new Error('Book not found');
        }
        const bookInfo = response.data.items[0].volumeInfo;
        return new Book({
            isbn: isbn,
            title: bookInfo.title,
            authors: bookInfo.authors,
            description: bookInfo.description,
            coverImage: bookInfo.imageLinks.thumbnail,
            publisher: bookInfo.publisher,
            parutionYear: bookInfo.publishedDate,
            categories: bookInfo.categories,
        });
    }
};

export default bookService;