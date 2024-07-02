import axios from 'axios';
import Book from "../models/book.model";
import User from "../models/user.model";
import BookBox from "../models/bookbox.model";
import {notifyUser} from "./user.service";

const bookService = {
    async getBookBoxBooks(bookboxId: string) {
        const bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        const books = [];
        for (const bookId of bookBox.books) {
            const book = await Book.findById(bookId);
            if (book) {
                books.push(book);
            }
        }
        return books;
    },

    // Helper function to fetch or create a book
    async addBook(request: any) {
        let book = await Book.findOne({qrCodeId: request.body.qrCodeId});
        if (!book) {
            book = new Book({
                qrCodeId: request.body.qrCodeId,
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
        }
        if (!book.qrCodeId) {
            throw new Error('Book\'s QR code ID is required');
        }
        if (!book.title) {
            throw new Error('Book\'s title is required');
        }
        let bookBox = await BookBox.findById(request.body.bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }

        // check if the book is already in a bookbox somewhere
        const bookBoxes = await BookBox.find({ books: book.id });
        if (bookBoxes.length > 0) {
            throw new Error('Book is supposed to be in the book box ' + bookBoxes[0].name);
        }

        bookBox.books.push(book.id);
        await this.updateBooks(book, request, true);
        await this.notifyAllUsers(book, 'added to', bookBox.name);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book.id);
        return {bookId : book.id, books : bookBox.books};
    },

    async getBookFromBookBox(qrCode: string, request: any, bookboxId: string) {
        // check if the book exists
        let book = await Book.findOne({qrCodeId: qrCode});
        if (!book) {
            throw new Error('Book not found');
        }
        // check if the bookbox exists
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        // check if the book is in the bookbox
        if (bookBox.books.includes(book.id)) {
            bookBox.books.splice(bookBox.books.indexOf(book.id), 1);
        } else {
            throw new Error('Book not found in bookbox');
        }

        await this.updateBooks(book, request, false);
        await this.notifyAllUsers(book, 'removed from', bookBox.name);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book.id);
        return {book: book, books: bookBox.books};
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
                book.givenHistory.push({username: username, timestamp: new Date()});
            } else { // if the book is taken
                book.takenHistory.push({username: username, timestamp: new Date()});
            }
        } else { // if the user is not authenticated, username is 'guest'
            if (given) { // if the book is given
                book.givenHistory.push({username: "guest", timestamp: new Date()});
            } else { // if the book is taken
                book.takenHistory.push({username: "guest", timestamp: new Date()});
            }
        }
        const books : any = await Book.find({title: book.title});
        for (let i = 0; i < books.length; i++) {
            // Update the dateLastAction field for all books with the same title
            // to indicate that this book has been looked at recently
            books[i].dateLastAction = Date.now;
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
                return bookBox.books.includes(book.id);
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
                const aDate = a.dateLastAction?.getTime() ?? 0;
                const bDate = b.dateLastAction?.getTime() ?? 0;
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
            books[i].bookboxPresence = [];
            for (let j = 0; j < bookBoxes.length; j++) {
                if (bookBoxes[j].books.includes(books[i]._id.toString())) {
                    // @ts-ignore
                    books[i].bookboxPresence.push(bookBoxes[j]._id);
                }
            }
            // Remove the books that are not present in any bookbox
            // @ts-ignore
            if (books[i].bookboxPresence.length === 0) {
                books.splice(i, 1);
                i--;
            }
        }

        return books;
    },

    async getBook(id: string) {
        return Book.findById(id);
    },

    async alertUsers(request : any) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw new Error('User not found');
        }
        const users = await User.find({getAlerted: true});
        for (let i = 0; i < users.length; i++) {
            if (users[i].username !== user.username) {
                await notifyUser(users[i].id, `The user ${user.username} wants to get the book "${request.body.title}" ! If you have it, please feel free to add it to one of our book boxes !`);
            }
        }

        return {message: 'Alert sent'};
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

    async addNewBookbox(request: any) {
        const bookBox = new BookBox({
            name: request.body.name,
            books: [],
            location: [request.body.longitude, request.body.latitude],
            infoText: request.body.infoText,
        });
        await bookBox.save();
        return bookBox;
    },

    async notifyAllUsers(book: any, action: string, bookBoxName: string) {
        const users = await User.find();
        for (let i = 0; i < users.length; i++) {
            const relevance = await this.getBookRelevance(book, users[i]);
            if (relevance > 0 || users[i].favoriteBooks.includes(book.id)) {
                await notifyUser(users[i].id, `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
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