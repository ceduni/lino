import axios from 'axios';
import mongoose from 'mongoose';
import BookBox from "../bookboxes/bookbox.model";
import {newErr} from "../services/utilities";
import { 
    BookSearchQuery,
    IBook,
    ITransaction
} from '../types/book.types';

const bookService = {

    async getBookInfoFromISBN(request: { params: { isbn: string } }) {
        const isbn = request.params.isbn;
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

    // Function that searches for books across all bookboxes based on keyword search and ordering filters
    // Optimized using MongoDB aggregation pipeline for better performance
    async searchBooks(request: { query: BookSearchQuery }) {
        const { kw, cls = 'by title', asc = true } = request.query;

        // Build aggregation pipeline
        const pipeline: any[] = [
            // Unwind the books array to work with individual books
            { $unwind: '$books' },
            
            // Add bookbox information to each book
            {
                $addFields: {
                    'books.bookboxId': { $toString: '$_id' },
                    'books.bookboxName': '$name'
                }
            }
        ];

        // Add keyword filtering stage if keyword is provided
        if (kw) {
            // Use text search if available, otherwise use regex
            pipeline.push({
                $match: {
                    $or: [
                        { 'books.title': { $regex: kw, $options: 'i' } },
                        { 'books.authors': { $regex: kw, $options: 'i' } },
                        { 'books.categories': { $regex: kw, $options: 'i' } }
                    ]
                }
            });
        }

        // Add sorting stage
        let sortField: string;
        let sortOrder = asc ? 1 : -1;

        switch (cls) {
            case 'by title':
                sortField = 'books.title';
                break;
            case 'by author':
                sortField = 'books.authors';
                break;
            case 'by year':
                sortField = 'books.parutionYear';
                break;
            case 'by recent activity':
                sortField = 'books.dateAdded';
                break;
            default:
                sortField = 'books.title';
        }

        pipeline.push({ $sort: { [sortField]: sortOrder } });

        // Project the final structure
        pipeline.push({
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
                bookboxId: '$books.bookboxId',
                bookboxName: '$books.bookboxName'
            }
        });

        // Execute the aggregation pipeline
        const results = await BookBox.aggregate(pipeline);
        
        return results;
    },

    async getBook(id: string) {
        // Use aggregation pipeline to efficiently find book by ID
        const pipeline = [
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
