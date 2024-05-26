import axios from 'axios';
import Book from "../models/book.model";

// Helper function to fetch or create a book
// This function tries to find a book in the database. If not found, it gets info from Google Books API and creates a new book entry.
async function fetchOrCreateBook(isbn: any) {
    let book = await Book.findById(isbn); // Look for the book by ISBN
    if (!book) { // If book doesn't exist
        // Make an API call to Google Books
        const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}`);
        const data = response.data;

        if (data.totalItems === 0) { // If Google Books doesn't find it either
            throw new Error('Book not found');
        }

        const volumeInfo = data.items[0].volumeInfo; // Get the book details

        // Create a new book document based on the API data
        book = new Book({
            _id: isbn,
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
}

const bookService = {
    fetchOrCreateBook
};

export default bookService;