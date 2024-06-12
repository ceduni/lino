import axios from 'axios';
import Book from "../models/book.model";
import mongoose from "mongoose";
import User from "../models/user.model";
import BookBox from "../models/bookbox.model";
import {notifyUser} from "./user.service";

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
        if (!book.title) {
            throw new Error('Book\'s title is required');
        }
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        bookBox.books.push(book.id);
        await this.updateBooks(book, request, true);
        await this.notifyAllUsers(book, 'added to', bookBox.name);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book.id);
        return book.id;
    },

    async addExistingBook(id: string, request: any, bookboxId: string) {
        // check if the book exists
        let book = await Book.findById(id);
        if (!book) {
            throw new Error('Book not found');
        }
        // check if the bookbox exists
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        // check if the book is already in a bookbox somewhere
        const bookBoxes = await BookBox.find({ books: book.id });
        if (bookBoxes.length > 0) {
            throw new Error('Book is supposed to be in the book box ' + bookBoxes[0].name);
        }

        await this.updateBooks(book, request, true);
        await this.notifyAllUsers(book, 'added to', bookBox.name);
        bookBox.books.push(book._id);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book._id.toString());
        return book;
    },

    async getBookFromBookBox(id: string, request: any, bookboxId: string) {
        // check if the book exists
        let book = await Book.findById(id);
        if (!book) {
            throw new Error('Book not found');
        }
        // check if the bookbox exists
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        // check if the book is in the bookbox
        if (bookBox.books.includes(book._id)) {
            bookBox.books.splice(bookBox.books.indexOf(book._id), 1);
        } else {
            throw new Error('Book not found in bookbox');
        }

        await this.updateBooks(book, request, false);
        await this.notifyAllUsers(book, 'removed from', bookBox.name);
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

                if (!user.trackedBooks.includes(bookId)) {
                    // add the book to the user's tracked books if it's not already there
                    user.trackedBooks.push(bookId);

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
            // Push the user's username and the current timestamp to the book's history
            // @ts-ignore
            const userId = request.user.id;
            const user = await User.findById(userId);
            if (!user) {
                throw new Error('User not found');
            }
            const username = user.username;
            if (given) { // if the book is given
                book.given_history.push({username: username, timestamp: new Date()});
            } else { // if the book is taken
                book.taken_history.push({username: username, timestamp: new Date()});
            }
        } else { // if the user is not authenticated, username is 'guest'
            if (given) { // if the book is given
                book.given_history.push({username: "guest", timestamp: new Date()});
            } else { // if the book is taken
                book.taken_history.push({username: "guest", timestamp: new Date()});
            }
        }
        const books : any = await Book.find({title: book.title});
        for (let i = 0; i < books.length; i++) {
            // Update the date_last_action field for all books with the same title
            // to indicate that this book has been looked at recently
            books[i].date_last_action = Date.now;
        }
    },

    async getBookInfoFromISBN(isbn: string) {
        const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}`);
        if (response.data.totalItems === 0) {
            throw new Error('Book not found');
        }
        const bookInfo = response.data.items[0].volumeInfo;
        const parutionYear = bookInfo.publishedDate ? parseInt(bookInfo.publishedDate.substring(0, 4)) : null;
        return {
            isbn: isbn,
            title: bookInfo.title,
            authors: bookInfo.authors,
            description: bookInfo.description,
            coverImage: bookInfo.imageLinks.thumbnail,
            publisher: bookInfo.publisher,
            parutionYear: parutionYear,
            categories: bookInfo.categories,
        };
    },


    // Helper function to get specific books from the database
    async searchBooks(request : any) {
        const categories = request.query.cat;
        let books;
        if (categories) {
            books = await Book.find({ categories: categories });
        } else {
            books = await Book.find();
        }
        const keywords = request.query.kw;
        if (keywords) {
            books = books.filter((book) => {
                return book.title.includes(keywords) || book.authors.includes(keywords);
            });
        }
        const pmt = request.query.pmt; // a bool to determine whether we want the books with more or less than X pages
        const pg = request.query.pg; // the number of pages
        if (pmt && pg) {
            if (pmt === 'true') {
                books = books.filter((book) => {
                    // @ts-ignore
                    return book.pages >= pg;
                });
            } else {
                books = books.filter((book) => {
                    // @ts-ignore
                    return book.pages <= pg;
                });
            }
        }
        const bf = request.query.bf; // a bool to determine whether we want the books before or after X year
        const py = request.query.py; // the year
        if (bf && py) {
            if (bf === 'true') {
                books = books.filter((book) => {
                    // @ts-ignore
                    return book.parutionYear <= py;
                });
            } else {
                books = books.filter((book) => {
                    // @ts-ignore
                    return book.parutionYear >= py;
                });
            }
        }
        const pub = request.query.pub; // the publisher
        if (pub) {
            books = books.filter((book) => {
                // @ts-ignore
                return book.publisher === pub;
            });
        }
        const bbid = request.query.bbid; // the bookbox id
        if (bbid) {
            const bookBox = await BookBox.findById(bbid);
            if (!bookBox) {
                throw new Error('Bookbox not found');
            }
            books = books.filter((book) => {
                return bookBox.books.includes(book._id);
            });
        }

        // classify : ['by title', 'by author', 'by year', 'by most recent activity']
        let classify = request.query.cls;
        if (!classify) {
            classify = 'by title'; // default value
        }
        let asc = request.query.asc === 'true';
        if (classify === 'by title') {
            books.sort((a, b) => {
                if (asc) {
                    return a.title.localeCompare(b.title); // ascending order (from a to z)
                } else {
                    return -a.title.localeCompare(b.title); // descending order (from z to a)
                }
            });
        } else if (classify === 'by author') {
            books.sort((a, b) => {
                const aAuthor = a.authors[0] ?? 'anon';
                const bAuthor = b.authors[0] ?? 'anon';
                if (asc) {
                    return aAuthor.localeCompare(bAuthor);
                } else {
                    return bAuthor.localeCompare(aAuthor);
                }
            });
        } else if (classify === 'by year') {
            books.sort((a, b) => {
                const aYear = a.parutionYear ?? 0;
                const bYear = b.parutionYear ?? 0;
                if (asc) {
                    return aYear - bYear;
                } else {
                    return bYear - aYear;
                }
            });
        } else if (classify === 'by recent activity') {
            books.sort((a, b) => {
                const aDate = a.date_last_action?.getTime() ?? 0;
                const bDate = b.date_last_action?.getTime() ?? 0;
                if (asc) {
                    return aDate - bDate;
                } else {
                    return bDate - aDate;
                }
            });
        }
        // Finally, only return the books that are present in bookboxes
        const bookBoxes = await BookBox.find();

        // Add bookbox_presence property to each book, only for this function
        for (let i = 0; i < books.length; i++) {
            // @ts-ignore
            books[i] = books[i].toObject(); // Convert document to a plain JavaScript object
            // @ts-ignore
            books[i].bookbox_presence = [];
            for (let j = 0; j < bookBoxes.length; j++) {
                if (bookBoxes[j].books.includes(books[i]._id)) {
                    // @ts-ignore
                    books[i].bookbox_presence.push(bookBoxes[j]._id);
                }
            }
            // Remove the books that are not present in any bookbox
            // @ts-ignore
            if (books[i].bookbox_presence.length === 0) {
                books.splice(i, 1);
                i--;
            }
        }

        return books;
    },

    // Function that returns 1 if the book is relevant to the user by his keywords, 0 otherwise
    async getBookRelevance(book: any, user: any) {
        // @ts-ignore
        const keywords = user.notificationKeyWords.map(keyword => new RegExp(keyword, 'i'));
        const properties = [book.title, ...book.authors, ...book.categories];

        for (let i = 0; i < properties.length; i++) {
            for (let j = 0; j < keywords.length; j++) {
                if (keywords[j].test(properties[i])) {
                    return 1;
                }
            }
        }

        return 0;
    },

    async notifyAllUsers(book: any, action: string, bookBoxName: string) {
        const users = await User.find();
        // Notify all users who have notification keywords corresponding to the book
        for (let i = 0; i < users.length; i++) {
            const relevance = await this.getBookRelevance(book, users[i]);
            if (relevance > 0) {
                await notifyUser(users[i].id, `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
            }
        }

        // Notify all users who have the book in their favorites
        for (let i = 0; i < users.length; i++) {
            if (users[i].favoriteBooks.includes(book.id)) {
                await notifyUser(users[i].id, `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
            }
        }

    },


    async alertUsers(username: string, title: string) {
        const users = await User.find({getAlerted: true});
        for (let i = 0; i < users.length; i++) {
            if (users[i].username !== username) {
                await notifyUser(users[i].id, `The user ${username} wants to get the book "${title}" ! 
                If you have it, please feel free to add it to one of our book boxes !`);
            }
        }
    },

    async clearCollection() {
        await Book.deleteMany({});
        const bookBoxes = await BookBox.find();
        for (let i = 0; i < bookBoxes.length; i++) {
            bookBoxes[i].books = [];
            await bookBoxes[i].save();
        }
    }

};

export default bookService;