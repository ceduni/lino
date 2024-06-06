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
            const user = await User.findById(userId);
            if (!user) {
                throw new Error('User not found');
            }
            const username = user.username;
            if (given) {
                book.given_history.push({username: username, timestamp: new Date()});
            } else {
                book.taken_history.push({username: username, timestamp: new Date()});
            }
        } else {
            if (given) {
                book.given_history.push({username: "guest", timestamp: new Date()});
            } else {
                book.taken_history.push({username: "guest", timestamp: new Date()});
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
            if (pmt) {
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
            if (bf) {
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
        // classify : ['by title', 'by author', 'by year', 'by most recent activity']
        let classify = request.query.cls;
        if (!classify) {
            classify = 'by recent activity';
        }
        let asc = request.query.asc === 'true';
        if (classify === 'by title') {
            books.sort((a, b) => {
                if (asc) {
                    return a.title.localeCompare(b.title);
                } else {
                    return -a.title.localeCompare(b.title);
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
        return books;
    },

};

export default bookService;