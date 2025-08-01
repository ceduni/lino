import axios from 'axios';
import mongoose from 'mongoose';
import { BookBox } from "../models";
import { newErr } from "../utilities/utilities";

const bookService = {

    async getBookInfoFromISBN(isbn: string) {
        const response = await axios.get(`https://www.googleapis.com/books/v1/volumes?q=isbn:${isbn}&key=${process.env.GOOGLE_API_KEY}`);
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

    async getBook(id: string) {
        // Use aggregation pipeline to efficiently find book by ID
        const pipeline = [
            // Filter out inactive bookboxes first
            { $match: { isActive: true } },
            
            // Unwind the books array
            { $unwind: '$books' },
            
            // Match the specific book ID
            { $match: { 'books._id': new mongoose.Types.ObjectId(id) } },
            
            // Project the result with bookbox information
            {
                $project: {
                    _id: { $toString: '$books._id' },
                    isbn: { $ifNull: ['$books.isbn', 'Unknown ISBN'] },
                    title: '$books.title',
                    authors: { $ifNull: ['$books.authors', []] },
                    description: { $ifNull: ['$books.description', 'No description available'] },
                    coverImage: { $ifNull: ['$books.coverImage', 'No cover image available'] },
                    publisher: { $ifNull: ['$books.publisher', 'Unknown publisher'] },
                    categories: { $ifNull: ['$books.categories', ['Uncategorized']] },
                    parutionYear: '$books.parutionYear',
                    pages: '$books.pages',
                    dateAdded: { $ifNull: ['$books.dateAdded', new Date()] },
                    bookboxId: { $toString: '$_id' },
                    bookboxName: '$name'
                }
            },
            
            // Limit to 1 result since we're looking for a specific book
            { $limit: 1 }
        ];

        const results = await BookBox.aggregate(pipeline);
        return results.length > 0 ? results[0] : null;
    },
 
};

export default bookService;
