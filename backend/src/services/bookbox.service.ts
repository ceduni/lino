import { User, BookBox } from "../models";
import { NotificationService, TransactionService } from ".";
import { newErr } from "../utilities/utilities";
import { 
    IBook,
} from '../types';

const bookboxService = {
    async getBookBox(bookBoxId: string) {
        const bookBox = await BookBox.findById(bookBoxId);
        if (!bookBox) {
            throw new Error('Bookbox not found');
        }
        return bookBox;
    },

    // Add a book to a bookbox as a nested document
    async addBook({
        bookboxId,
        title,
        isbn,
        authors,
        description,
        coverImage,
        publisher,
        parutionYear,
        pages,
        categories,
        userId
     }: {
        bookboxId: string,
        title: string,
        isbn?: string,
        authors?: string[],
        description?: string,
        coverImage?: string,
        publisher?: string,
        parutionYear?: number,
        pages?: number,
        categories?: string[],
        userId?: string
    }) {
        
        if (!title) {
            throw newErr(400, 'Book title is required');
        }

        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }
        if (!bookBox.isActive) {
            throw newErr(400, 'This bookbox is not active');
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
        const username = userId ? (await User.findById(userId))?.username || 'guest' : 'guest';
        await TransactionService.createTransaction(username, 'added', isbn ? isbn : '', bookboxId);

        // Notify users about the new book
        await NotificationService.notifyRelevantUsers(
            username,
            newBook, 
            bookBox._id.toString()
        );

        // Increment user's added books count
        if (userId) {
            const user = await User.findById(userId);
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

    async getBookFromBookBox(
        bookboxId: string,
        bookId: string,
        userId?: string,
    ) {
        // Find the bookbox
        let bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }
        if (!bookBox.isActive) {
            throw newErr(400, 'This bookbox is not active');
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
        const username = userId ? (await User.findById(userId))?.username || 'guest' : 'guest';
        await TransactionService.createTransaction(username, 'took', book.isbn ? book.isbn : '', bookboxId);

        // Increment user's saved books count
        if (userId) {
            const user = await User.findById(userId);
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

    async clearCollection() {
        await BookBox.deleteMany({});
    },

    async followBookBox(
        id: string,
        bookboxId: string
    ) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (!user.followedBookboxes.includes(bookboxId)) {
            user.followedBookboxes.push(bookboxId);
            await user.save();
        }
        return { message: 'Bookbox followed successfully' };
    },

    async unfollowBookBox(
        id: string,
        bookboxId: string
    ) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        user.followedBookboxes = user.followedBookboxes.filter(id => id !== bookboxId);
        await user.save();
        return { message: 'Bookbox unfollowed successfully' };
    },
};

export default bookboxService;
