import BookBox from "../bookboxes/bookbox.model";
import { getBoroughId } from "../services/borough.id.generator";
import { newErr } from "../services/utilities";
import Thread from "../threads/thread.model";
import Transaction from "../transactions/transaction.model";
import { BookSearchQuery } from "../types";

const searchService = {
    async searchBooks(request: { query: BookSearchQuery }) {
        const { q, cls = 'by title', asc = true } = request.query;

        // Build aggregation pipeline
        const pipeline: any[] = [
            // Filter out inactive bookboxes first
            { $match: { isActive: true } },
            
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
        if (q) {
            // Use text search if available, otherwise use regex
            pipeline.push({
                $match: {
                    $or: [
                        { 'books.title': { $regex: q, $options: 'i' } },
                        { 'books.authors': { $regex: q, $options: 'i' } },
                        { 'books.categories': { $regex: q, $options: 'i' } }
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

    async searchBookboxes(request: { 
        query: { 
            q?: string; 
            cls?: string; 
            asc?: boolean; 
            longitude?: number; 
            latitude?: number; 
        } 
    }) {
        const q= request.query.q;
        let bookBoxes = await BookBox.find();

        if (q) {
            // Filter using regex for more flexibility
            const regex = new RegExp(q, 'i');
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
                    const aDist = calculateDistance(userLatitude, userLongitude, a.latitude, a.longitude);
                    const bDist = calculateDistance(userLatitude, userLongitude, b.latitude, b.longitude);
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

        // Only return the necessary fields
        return bookBoxes.map(bookBox => ({
            id: bookBox._id.toString(),
            name: bookBox.name,
            infoText: bookBox.infoText,
            longitude: bookBox.longitude,
            latitude: bookBox.latitude,
            booksCount: bookBox.books.length,
            image: bookBox.image,
            owner: bookBox.owner,
            boroughId: bookBox.boroughId,
            isActive: bookBox.isActive
        }));
    },

    async findNearestBookboxes(
        longitude: number, 
        latitude: number, 
        maxDistance: number = 5, 
        searchByBorough: boolean = false
    ) {
        if (!longitude || !latitude) {
            throw newErr(400, 'Longitude and latitude are required');
        }

        const bookboxes = await BookBox.find();

        let nearbyBookboxes;

        if (searchByBorough) {
            nearbyBookboxes = bookboxes.filter(async bookbox => {
                const locationBoroughId = await getBoroughId(latitude, longitude);
                return bookbox.boroughId === locationBoroughId;
            });
        } else {
            nearbyBookboxes = bookboxes.filter(bookbox => {
                const distance = calculateDistance(latitude, longitude, bookbox.latitude, bookbox.longitude);
                return distance <= maxDistance;
            });
        }

        return nearbyBookboxes.map(bookbox => ({
            id: bookbox._id.toString(),
            name: bookbox.name,
            infoText: bookbox.infoText,
            longitude: bookbox.longitude,
            latitude: bookbox.latitude,
            booksCount: bookbox.books.length,
            image: bookbox.image,
            owner: bookbox.owner,
            boroughId: bookbox.boroughId,
            isActive: bookbox.isActive
        }));
    },

    async searchThreads(request: { query: { q?: string; cls?: string; asc?: boolean } }) {
        const query = request.query.q;
        let threads = await Thread.find();

        if (query) {
            // Filter using regex for more flexibility
            const regex = new RegExp(query, 'i');
            threads = threads.filter(thread =>
                regex.test(thread.bookTitle) || regex.test(thread.title) || regex.test(thread.username)
            );
        }

        // classify : ['by recent activity', 'by number of messages', 'by creation date']
        let classify = request.query.cls || 'by recent activity';
        const asc = request.query.asc; // Boolean

        if (classify === 'by recent activity') {
            threads.sort((a, b) => {
                const aDate = a.messages.length > 0 ? a.messages[a.messages.length - 1].timestamp.getTime() : 0;
                const bDate = b.messages.length > 0 ? b.messages[b.messages.length - 1].timestamp.getTime() : 0;
                return asc ? aDate - bDate : bDate - aDate;
            });
        } else if (classify === 'by number of messages') {
            threads.sort((a, b) => {
                return asc ? a.messages.length - b.messages.length : b.messages.length - a.messages.length;
            });
        } else if (classify === 'by creation date') {
            threads.sort((a, b) => { // if asc, most recent first
                const aDate = a.timestamp.getTime();
                const bDate = b.timestamp.getTime();
                return asc ? aDate - bDate : bDate - aDate;
            });
        }

        return { threads: threads };
    },

    
    async searchMyManagedBookboxes(request: any) {
        try {
            let bookboxes = await BookBox.find({ owner: request.user.username });
            if (!bookboxes || bookboxes.length === 0) {
                return [];
            }
            const q = request.query.q;
            if (q) {
                bookboxes = bookboxes.filter((bookbox) => bookbox.name.toLowerCase().includes(q.toLowerCase()));
            }   
            const cls = request.query.cls;
            const asc = request.query.asc === 'true';

            if (cls === 'by name') {
                bookboxes.sort((a, b) => {
                    return asc ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name);
                });
            } else if (cls === 'by number of books') {
                bookboxes.sort((a, b) => {
                    return asc ? a.books.length - b.books.length : b.books.length - a.books.length;
                });
            }

            return bookboxes;
        } catch (error) {
            throw newErr(500, 'Failed to retrieve bookboxes');
        }
    },

    async searchTransactionHistory(request: { query: { username?: string; bookTitle?: string; bookboxId?: string; limit?: number } }) {
        const { username, bookTitle, bookboxId, limit } = request.query;
        
        let filter: any = {};
        if (username) filter.username = username;
        if (bookTitle) filter.bookTitle = new RegExp(bookTitle, 'i');
        if (bookboxId) filter.bookboxId = bookboxId;

        let query = Transaction.find(filter).sort({ timestamp: -1 });
        if (limit) {
            query = query.limit(parseInt(limit.toString()));
        }

        return await query.exec();
    }
}

function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in km
        
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
        Math.sin(dLon/2) * Math.sin(dLon/2);
        
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
}

export default searchService;