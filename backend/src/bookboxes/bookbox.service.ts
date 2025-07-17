import BookBox from "./bookbox.model";
import User from "../users/user.model";
import Transaction from "../transactions/transaction.model";
import NotificationService from "../notifications/notification.service";
import {newErr} from "../services/utilities";
import { 
    BookAddData,
    IBook,
} from '../types/book.types';
import { AuthenticatedRequest } from '../types/common.types';
import { getBoroughId } from "../services/borough.id.generator";
import TransactionService from "../transactions/transaction.service";

const bookboxService = {
    async getBookBox(bookBoxId: string) {
        const bookBox = await BookBox.findById(bookBoxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        return bookBox;
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
        await TransactionService.createTransaction(username, 'added', title, bookboxId);

        // Notify users about the new book
        await NotificationService.notifyRelevantUsers(
            username,
            newBook, 
            bookBox._id.toString()
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
        await TransactionService.createTransaction(username, 'took', book.title, bookboxId);

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
            const userLongitude = request.query.longitude;
            const userLatitude = request.query.latitude;
            if (!userLongitude || !userLatitude) {
                throw newErr(401, 'Location is required for this classification');
            }
            bookBoxes.sort((a, b) => {
                if (a.longitude && a.latitude && b.longitude && b.latitude) {
                    // calculate the distance between the user's location and the bookbox's location
                    const aDist = this.calculateDistance(userLatitude, userLongitude, a.latitude, a.longitude);
                    const bDist = this.calculateDistance(userLatitude, userLongitude, b.latitude, b.longitude);
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

    async clearCollection() {
        await BookBox.deleteMany({});
    },

    async followBookBox(request: AuthenticatedRequest & { params: { bookboxId: string } }) {
        const bookboxId = request.params.bookboxId;
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (!user.followedBookboxes.includes(bookboxId)) {
            user.followedBookboxes.push(bookboxId);
            await user.save();
        }
        return { message: 'Bookbox followed successfully' };
    },

    async unfollowBookBox(request: AuthenticatedRequest & { params: { bookboxId: string } }) {
        const bookboxId = request.params.bookboxId;
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        user.followedBookboxes = user.followedBookboxes.filter(id => id !== bookboxId);
        await user.save();
        return { message: 'Bookbox unfollowed successfully' };
    },

    async findNearestBookboxes(longitude: number, latitude: number, maxDistance: number = 5) {
        if (!longitude || !latitude) {
            throw newErr(400, 'Longitude and latitude are required');
        }

        const bookboxes = await BookBox.find();

        const nearbyBookboxes = bookboxes.filter(bookbox => {
            const distance = this.calculateDistance(latitude, longitude, bookbox.latitude, bookbox.longitude);
            return distance <= maxDistance;
        });

        return nearbyBookboxes;
    },

    calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
        const R = 6371; // Earth's radius in km
        
        const dLat = (lat2 - lat1) * Math.PI / 180;
        const dLon = (lon2 - lon1) * Math.PI / 180;

        const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                  Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
                  Math.sin(dLon/2) * Math.sin(dLon/2);
        
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c;
    }
};

export default bookboxService;
