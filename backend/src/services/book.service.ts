import axios from 'axios';
import Book from "../models/book.model";
import User from "../models/user.model";
import BookBox from "../models/bookbox.model";
import {notifyUser} from "./user.service";
import {newErr} from "./utilities";

const bookService = {
    async getBookBox(bookBoxId: string) {
        const bookBox = await BookBox.findById(bookBoxId);
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
        return {
            id: bookBox.id,
            name: bookBox.name,
            location: bookBox.location,
            infoText: bookBox.infoText,
            books: books,
        };
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
            throw newErr(400, 'Book\'s QR code ID is required');
        }
        if (!book.title) {
            throw newErr(400, 'Book\'s title is required');
        }
        let bookBox = await BookBox.findById(request.body.bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }

        // check if the book is already in a bookbox somewhere
        const bookBoxes = await BookBox.find({ books: book.id });
        if (bookBoxes.length > 0) {
            throw newErr(400, 'Book is supposed to be in the book box ' + bookBoxes[0].name);
        }

        bookBox.books.push(book.id);
        await this.updateBooks(book, request, true);
        await this.notifyAllUsers(book, 'added to', bookBox.name);
        await book.save();
        await bookBox.save();
        await this.updateUserEcoImpact(request, book.id);
        return {bookId : book.id, books : bookBox.books};
    },

    async getBookFromBookBox(request: any) {
        const qrCode = request.params.bookQRCode;
        const bookboxId = request.params.bookboxId;
        // check if the book exists
        let book = await Book.findOne({qrCodeId: qrCode});
        if (!book) {
            throw newErr(404, 'Book not found');
        }
        // check if the bookbox exists
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }
        // check if the book is in the bookbox
        if (bookBox.books.includes(book.id)) {
            bookBox.books.splice(bookBox.books.indexOf(book.id), 1);
        } else {
            throw newErr(404, 'Book not found in bookbox');
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
                throw newErr(404, 'User not found');
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

    async getBookInfoFromISBN(request: any) {
        const isbn = request.params.isbn;
        const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}`);
        if (response.data.totalItems === 0) {
            throw newErr(404, 'Book not found');
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
            pages: bookInfo.pageCount,
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
        const pmt = request.query.pmt === true; // a bool to determine whether we want the books with more or less than X pages
        const pg = request.query.pg; // the number of pages
        if (pg) {
            books = books.filter((book) => {
                const bookPages = book.pages;
                if (!bookPages) return true;
                return pmt ? bookPages >= pg : bookPages <= pg;
            });
        }
        const bf = request.query.bf === true; // a bool to determine whether we want the books before or after X year
        const py = request.query.py; // the year
        if (py) {
            books = books.filter((book) => {
                // @ts-ignore
                const bookYear = book.parutionYear;
                if (!bookYear) return true;
                if (bf) {
                    // If bf is true, filter for books before the year
                    return bookYear <= py;
                } else {
                    // If bf is false, filter for books after the year
                    return bookYear >= py;
                }
            });
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
                throw newErr(404, 'Bookbox not found');
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
        let asc = request.query.asc === true;
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

    async searchBookboxes(request : any) {
        const kw = request.query.kw;
        let bookBoxes = await BookBox.find();
        if (kw) {
            bookBoxes = bookBoxes.filter((bookBox) => {
                // @ts-ignore
                return bookBox.name.includes(kw) || bookBox.infoText.includes(kw);
            });
        }
        const cls = request.query.cls;
        let asc = request.query.asc === true;
        if (cls === 'by name') {
            bookBoxes.sort((a, b) => {
                if (asc) {
                    return a.name.localeCompare(b.name);
                } else {
                    return b.name.localeCompare(a.name);
                }
            });
        } else if (cls === 'by location') {
            const selfLoc = [request.query.longitude, request.query.latitude];
            if (!selfLoc[0] || !selfLoc[1]) {
                throw newErr(400, 'Location is required for this classification');
            }
            bookBoxes.sort((a, b) => {
                const aLoc = a.location;
                const bLoc = b.location;
                // calculate the distance between the user's location and the bookbox's location
                const aDist = Math.sqrt((aLoc[0] - selfLoc[0]) ** 2 + (aLoc[1] - selfLoc[1]) ** 2);
                const bDist = Math.sqrt((bLoc[0] - selfLoc[0]) ** 2 + (bLoc[1] - selfLoc[1]) ** 2);
                // sort in ascending or descending order of distance
                if (asc) {
                    return aDist - bDist;
                } else {
                    return bDist - aDist;
                }
            });
        } else if (cls === 'by number of books') {
            bookBoxes.sort((a, b) => {
                if (asc) {
                    return a.books.length - b.books.length;
                } else {
                    return b.books.length - a.books.length;
                }
            });
        }

        // only return the ids of the bookboxes
        const bookBoxIds = bookBoxes.map((bookBox) => {
            return bookBox._id.toString();
        });
        // get the full bookbox objects
        let finalBookBoxes = [];
        for (let i = 0; i < bookBoxes.length; i++) {
            finalBookBoxes.push(await this.getBookBox(bookBoxIds[i]));
        }

        return finalBookBoxes;
    },

    async getBook(id: string) {
        return Book.findById(id);
    },

    async alertUsers(request : any) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
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
        await BookBox.deleteMany({});
    }

};

export default bookService;