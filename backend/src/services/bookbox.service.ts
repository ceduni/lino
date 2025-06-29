import BookBox from "../models/bookbox.model";
import User from "../models/user.model";
import Request from "../models/book.request.model";
import Transaction from "../models/transaction.model";
import {notifyUser} from "./user.service";
import {newErr} from "./utilities";
import bookService from "./book.service";
import { 
    BookAddData,
    IBook,
    IBookBox 
} from '../types/book.types';
import { IUser } from '../types/user.types';
import { AuthenticatedRequest } from '../types/common.types';

const bookboxService = {
    async getBookBox(bookBoxId: string) {
        const bookBox = await BookBox.findById(bookBoxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        return {
            id: bookBox.id,
            name: bookBox.name,
            image: bookBox.image,
            location: bookBox.location,
            infoText: bookBox.infoText,
            books: bookBox.books,
        };
    },

    // Add a book to a bookbox as a nested document
    async addBook(request: AuthenticatedRequest & { body: BookAddData; params: { bookboxId: string } }) {
        const { title, isbn, authors, description, coverImage, publisher, parutionYear, pages, categories } = request.body;
        const { bookboxId } = request.params;
        
        if (!title) {
            throw newErr(400, 'Book title is required');
        }

        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }

        // Create new book object
        const newBook: IBook = {
            isbn: isbn,
            title: title,
            authors: authors || [],
            description: description || "No description available",
            coverImage: coverImage || "No cover image",
            publisher: publisher || "Unknown Publisher",
            parutionYear: parutionYear || undefined,
            pages: pages || undefined,
            categories: categories || [],
            dateAdded: new Date()
        };

        // Add book to bookbox
        bookBox.books.push(newBook);
        await bookBox.save();

        // Get the added book with its generated ID
        const addedBook = bookBox.books[bookBox.books.length - 1];

        // Create transaction record
        const username = request.user ? (await User.findById(request.user.id))?.username || 'guest' : 'guest';
        await bookService.createTransaction(username, 'added', title, bookboxId);

        // Notify users about the new book
        await this.notifyRelevantUsers(
            username,
            newBook, 
            'added to', 
            bookBox.name, 
            bookBox._id?.toString() || ''
        );

        // Increment user's added books count
        if (request.user) {
            const user = await User.findById(request.user.id);
            if (user) {
                // Ensure the user has followed the bookbox
                if (!user.followedBookboxes.includes(bookBox._id.toString())) {
                    user.followedBookboxes.push(bookBox._id.toString());
                }
                user.numSavedBooks++;
                await user.save();
            }
        }

        return {bookId: addedBook._id?.toString(), books: bookBox.books};
    },

    async getBookFromBookBox(request: AuthenticatedRequest & { params: { bookId: string; bookboxId: string } }) {
        const bookId = request.params.bookId;
        const bookboxId = request.params.bookboxId;

        // Find the bookbox
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }

        // Find the book in the bookbox
        const bookIndex = bookBox.books.findIndex(book => book._id?.toString() === bookId);
        if (bookIndex === -1) {
            throw newErr(404, 'Book not found in bookbox');
        }

        const book = bookBox.books[bookIndex];
        
        // Remove the book from the bookbox
        bookBox.books.splice(bookIndex, 1);
        await bookBox.save();

        // Create transaction record
        const username = request.user ? (await User.findById(request.user.id))?.username || 'guest' : 'guest';
        await bookService.createTransaction(username, 'took', book.title, bookboxId);

        // Notify users about the book removal
        const bookForNotification: IBook = {
            _id: book._id?.toString(),
            isbn: book.isbn || "Unknown ISBN",
            title: book.title,
            authors: book.authors || [],
            description: book.description || "No description available",
            coverImage: book.coverImage || "No cover image",
            publisher: book.publisher || "Unknown Publisher",
            categories: book.categories || [],
            parutionYear: book.parutionYear || undefined,
            pages: book.pages || undefined,
            dateAdded: book.dateAdded || new Date(),
        };
        await this.notifyRelevantUsers(
            username,
            bookForNotification, 
            'removed from', 
            bookBox.name, 
            bookBox._id?.toString() || '');

        // Increment user's saved books count
        if (request.user) {
            const user = await User.findById(request.user.id);
            if (user) {
                // If the user doesn't follow this bookbox, add it to their followed bookboxes
                if (!user.followedBookboxes.includes(bookBox._id.toString())) {
                    user.followedBookboxes.push(bookBox._id.toString());
                }
                user.numSavedBooks++;
                await user.save();
            }
        }

        return {book: book, books: bookBox.books};
    },


    async searchBookboxes(request: { 
        query: { 
            kw?: string; 
            cls?: string; 
            asc?: boolean; 
            longitude?: number; 
            latitude?: number; 
        } 
    }) {
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
                if (aLoc && bLoc && selfLoc[0] && selfLoc[1]) {
                    // calculate the distance between the user's location and the bookbox's location
                    const aDist = Math.sqrt((aLoc[0] - selfLoc[0]) ** 2 + (aLoc[1] - selfLoc[1]) ** 2);
                    const bDist = Math.sqrt((bLoc[0] - selfLoc[0]) ** 2 + (bLoc[1] - selfLoc[1]) ** 2);
                    // sort in ascending or descending order of distance
                    return asc ? aDist - bDist : bDist - aDist;
                }
                return 0;
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

    async addNewBookbox(request: { 
        body: { 
            name: string; 
            image?: string; 
            longitude: number; 
            latitude: number; 
            infoText?: string; 
        } 
    }) {
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

    // Function that returns 1 if the book is relevant to the user by his keywords
    // or if he put that book title in a request, 0 otherwise
    async getBookRelevance(book: IBook, user: IUser) {
        const keywords = user.notificationKeyWords.map((keyword: string) => new RegExp(keyword, 'i'));
        const properties = [book.title, ...book.authors, ...book.categories];

        for (let i = 0; i < properties.length; i++) {
            for (let j = 0; j < keywords.length; j++) {
                if (keywords[j].test(properties[i])) {
                    return 1;
                }
            }
        }

        const requests = await Request.find();
        const regex = new RegExp(book.title, 'i');
        const matchingRequests = requests.filter(req => regex.test(req.bookTitle));
        
        for (const req of matchingRequests) {
            if (req.username === user.username) {
                return 1; // User has requested this book
            }
        }

        return 0;
    },

    async notifyRelevantUsers(username: string, book: IBook, action: string, bookBoxName: string, bookBoxId: string) {
        const users = await User.find();
        for (let i = 0; i < users.length; i++) {
            if (users[i].username === username) {
                continue; // Skip the user who added the book
            }

            var notify = false;

            const relevance = await this.getBookRelevance(book, users[i] as any);
            notify = relevance > 0;
            if (users[i].followedBookboxes.includes(bookBoxId)) {
                notify = true; // User follows this bookbox, so notify them
            }

            // Notify the user if the book is relevant to him
            if (notify) {
                await notifyUser(users[i].id,
                    "Book notification",
                    `The book "${book.title}" has been ${action} the bookbox "${bookBoxName}" !`);
            }
        }
    },

    async clearCollection() {
        await BookBox.deleteMany({});
    }
};

export default bookboxService;
