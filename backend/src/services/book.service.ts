import axios from 'axios';
import Book from "../models/book.model";
import User from "../models/user.model";
import BookBox from "../models/bookbox.model";
import Request from "../models/book.request.model";
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
            image: bookBox.image,
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

        // send a notification to the user who requested the book
        let requests = await Request.find();
        // Filter requests using regex to match similar titles
        const regex = new RegExp(book.title, 'i');
        requests = requests.filter(request => regex.test(request.bookTitle));
        for (let i = 0; i < requests.length; i++) {
            await notifyUser(requests[i].username, "Book notification",
                `The book "${book.title}" has been added to the bookbox "${bookBox.name}" to fulfill your request !`);
        }


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
                // push in the user's book history
                user.bookHistory.push({bookId: book.id, given: true});
            } else { // if the book is taken
                book.takenHistory.push({username: username, timestamp: new Date()});
                // push in the user's book history
                user.bookHistory.push({bookId: book.id, given: false});
            }
        } else { // if the user is not authenticated, username is 'guest'
            if (given) { // if the book is given
                book.givenHistory.push({username: "guest", timestamp: new Date()});
            } else { // if the book is taken
                book.takenHistory.push({username: "guest", timestamp: new Date()});
            }
        }

        let books = await Book.find();
        // Filter books using regex to match similar titles
        const regex = new RegExp(book.title, 'i');
        books = books.filter(b => regex.test(b.title));
        for (let i = 0; i < books.length; i++) {
            // Update the dateLastAction field for all books with the same title
            // to indicate that this book has been looked at recently
            // @ts-ignore
            books[i].dateLastAction = Date.now();
            await books[i].save();
        }
    },

    async getBookInfoFromISBN(request: any) {
        const isbn = request.params.isbn;
        const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}&key=${process.env.GOOGLE_BOOKS_API_KEY}`);
        if (response.data.totalItems === 0) {
            throw newErr(404, 'Book not found');
        }
        const bookInfo = response.data.items[0].volumeInfo;
        const parutionYear = bookInfo.publishedDate ? parseInt(bookInfo.publishedDate.substring(0, 4)) : undefined;
        const pageCount = bookInfo.pageCount ? parseInt(bookInfo.pageCount) : undefined;
        return {
            isbn: isbn,
            title: bookInfo.title || 'Unknown title',
            authors: bookInfo.authors || ['Unknown author'],
            description: bookInfo.description || 'No description available',
            coverImage: bookInfo.imageLinks?.thumbnail || 'No thumbnail available',
            publisher: bookInfo.publisher || 'Unknown publisher',
            parutionYear: parutionYear,
            categories: bookInfo.categories || ['Uncategorized'],
            pages: pageCount,
        };
    },


    // Function that searches for books based on the query parameters
    async searchBooks(request : any) {
        const { cat, kw, pmt, pg, bf, py, pub, bbid, cls = 'by title', asc = true } = request.query;

        let filter : any = {};

        if (cat) {
            const categories = Array.isArray(cat) ? cat : [cat];
            const categoryArray = categories.map((c) => new RegExp(c.trim(), 'i'));
            filter.categories = { $in: categoryArray };
        }

        if (kw) {
            const regex = new RegExp(kw, 'i');
            filter.$or = [
                { title: regex },
                { authors: regex }
            ];
        }

        if (py) {
            filter.parutionYear = bf ? { $lte: py } : { $gte: py };
        }

        if (pub) {
            filter.publisher = new RegExp(pub, 'i');
        }

        if (bbid) {
            const bookBox = await BookBox.findById(bbid);
            if (!bookBox) {
                throw new Error('Bookbox not found');
            }
            filter._id = { $in: bookBox.books };
        }

        let books = await Book.find(filter);

        if (pg) {
            const pageCount = parseInt(pg);
            books = books.filter((book) => {
                const bookPages = book.pages || 0;
                return pmt ? bookPages >= pageCount : bookPages <= pageCount;
            });
        }

        // Sorting
        const sortOptions : any = {};
        if (cls === 'by title') {
            sortOptions.title = asc ? 1 : -1;
        } else if (cls === 'by author') {
            sortOptions['authors.0'] = asc ? 1 : -1;
        } else if (cls === 'by year') {
            sortOptions.parutionYear = asc ? 1 : -1;
        } else if (cls === 'by recent activity') {
            sortOptions.dateLastAction = asc ? 1 : -1;
        }

        books = await Book.find(filter).sort(sortOptions);

        const bookBoxes = await BookBox.find();
        const finalBooks = [];
        for (let i = 0; i < books.length; i++) {
            const book = books[i].toObject();
            // @ts-ignore
            book.bookboxPresence = bookBoxes.filter((box) =>
                box.books.includes(book._id.toString())
            ).map(box => box._id);
            finalBooks.push(book);
        }

        return finalBooks;
    },


    async searchBookboxes(request: any) {
        const kw = request.query.kw;
        let bookBoxes = await BookBox.find();

        if (kw) {
            // Filter using regex for more flexibility
            const regex = new RegExp(kw, 'i');
            bookBoxes = bookBoxes.filter((bookBox) =>
                regex.test(bookBox.name) || regex.test(bookBox.infoText || '')
            );
        }

        const cls = request.query.cls;
        const asc = request.query.asc; // Boolean

        if (cls === 'by name') {
            bookBoxes.sort((a, b) => {
                return asc ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
            });
        } else if (cls === 'by location') {
            const selfLoc = [request.query.longitude, request.query.latitude];
            if (!selfLoc[0] || !selfLoc[1]) {
                throw newErr(401, 'Location is required for this classification');
            }
            bookBoxes.sort((a, b) => {
                const aLoc = a.location;
                const bLoc = b.location;
                // calculate the distance between the user's location and the bookbox's location
                const aDist = Math.sqrt((aLoc[0] - selfLoc[0]) ** 2 + (aLoc[1] - selfLoc[1]) ** 2);
                const bDist = Math.sqrt((bLoc[0] - selfLoc[0]) ** 2 + (bLoc[1] - selfLoc[1]) ** 2);
                // sort in ascending or descending order of distance
                return asc ? aDist - bDist : bDist - aDist;
            });
        } else if (cls === 'by number of books') {
            bookBoxes.sort((a, b) => {
                return asc ? a.books.length - b.books.length : b.books.length - a.books.length;
            });
        }


        // only return the ids of the bookboxes
        const bookBoxIds = bookBoxes.map((bookBox) => bookBox._id.toString());
        // get the full bookbox objects
        const finalBookBoxes = [];
        for (let i = 0; i < bookBoxIds.length; i++) {
            finalBookBoxes.push(await this.getBookBox(bookBoxIds[i]));
        }

        return finalBookBoxes;
    },

    async getBook(id: string) {
        return Book.findById(id);
    },

    async requestBookToUsers(request : any) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        const users = await User.find({getAlerted: true});
        for (let i = 0; i < users.length; i++) {
            if (users[i].username !== user.username) {
                await notifyUser(users[i].id,
                    "Book request",
                    `The user ${user.username} wants to get the book "${request.body.title}" ! If you have it, please feel free to add it to one of our book boxes !`);
            }
        }

        const newRequest = new Request({
            username: user.username,
            bookTitle: request.body.title,
            customMessage: request.body.customMessage,
        });
        await newRequest.save();
        return newRequest;
    },

    async deleteBookRequest(request : any) {
        const requestId = request.params.id;
        const requestToDelete = await Request.findById(requestId);
        if (!requestToDelete) {
            throw newErr(404, 'Request not found');
        }
        await requestToDelete.deleteOne();
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
            image: request.body.image,
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
            // Notify the user if the book is relevant to him or if it's one of his favorite books
            if (relevance > 0 || users[i].favoriteBooks.includes(book.id)) {
                await notifyUser(users[i].id,
                    "Book notification",
                    `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
            }
        }
    },


    async getBookRequests(request: any) {
        let username = request.query.username;
        if (!username) {
            return Request.find();
        } else {
            return Request.find({username: username});
        }
    },

    async clearCollection() {
        await Book.deleteMany({});
        await BookBox.deleteMany({});
    }

};

export default bookService;