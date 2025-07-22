import BookBox from "../bookboxes/bookbox.model";
import Issue from "../issues/issue.model";
import { getBoroughId } from "../services/borough.id.generator";
import { newErr } from "../services/utilities";
import Thread from "../threads/thread.model";
import Transaction from "../transactions/transaction.model";
import { AuthenticatedRequest, BookSearchQuery } from "../types";
import User from "../users/user.model";

const searchService = {
    async searchBooks(
        q?: string,
        cls: string = 'by title',
        asc: boolean = true,
        limit: number = 20,
        page: number = 1
    ) {
        // Get pagination parameters
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

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

        pipeline.push({ $skip: skipAmount });
        pipeline.push({ $limit: pageSize });

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


    async searchBookboxes(
        q?: string,
        cls: string = 'by name',
        asc: boolean = true,
        longitude?: number,
        latitude?: number,
        limit: number = 20,
        page: number = 1    
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        let filter: any = { isActive: true };
        
        if (q) {
            filter.$or = [
                { name: { $regex: q, $options: 'i' } },
                { infoText: { $regex: q, $options: 'i' } }
            ];
        }
        
        // Handle location sorting with $geoNear
        if (cls === 'by location') {
            if (!longitude || !latitude) {
                throw newErr(400, 'Location is required for this classification');
            }
            
            return await BookBox.aggregate([
                {
                    $geoNear: {
                        near: { 
                            type: 'Point', 
                            coordinates: [longitude, latitude] 
                        },
                        distanceField: 'distance',
                        spherical: true,
                        query: filter
                    }
                },
                { $sort: { distance: asc ? 1 : -1 } },
                { $skip: skipAmount },
                { $limit: pageSize },
                {
                    $project: {
                        _id: 1, name: 1, infoText: 1, longitude: 1, latitude: 1,
                        booksCount: 1, image: 1, owner: 1, boroughId: 1, isActive: 1,
                        distance: { $divide: ['$distance', 1000] } // Convert meters to km
                    }
                }
            ]);
        }
        
        // Handle other sorting with regular query + select
        let query = BookBox.find(filter);
        
        if (cls === 'by name') {
            query = query.sort({ name: asc ? 1 : -1 });
        } else if (cls === 'by number of books') {
            query = query.sort({ booksCount: asc ? 1 : -1 });
        }

        return await query
            .skip(skipAmount)
            .limit(pageSize)
            .select('_id name infoText longitude latitude booksCount image owner boroughId isActive')
            .lean();
    },

    async findNearestBookboxes(
        longitude: number, 
        latitude: number, 
        maxDistance: number = 5, 
        searchByBorough: boolean = false,
        limit: number = 20,
        page: number = 1
    ) {
        if (!longitude || !latitude) {
            throw newErr(400, 'Longitude and latitude are required');
        }

        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        if (searchByBorough) {
            // Get borough ID first
            const locationBoroughId = await getBoroughId(latitude, longitude);
            
            // Find bookboxes in the same borough
            const bookboxes = await BookBox.find({ 
                boroughId: locationBoroughId, 
                isActive: true 
            })
            .skip(skipAmount)
            .limit(pageSize)
            .select('_id name infoText longitude latitude booksCount image owner boroughId isActive')
            .lean();

            return bookboxes;
        } else {
            // Use $geoNear for accurate distance calculation
            const nearbyBookboxes = await BookBox.aggregate([
                {
                    $geoNear: {
                        near: { 
                            type: 'Point', 
                            coordinates: [longitude, latitude] 
                        },
                        distanceField: 'distance',
                        maxDistance: maxDistance * 1000, // Convert km to meters
                        spherical: true,
                        query: { isActive: true }
                    }
                },
                { $sort: { distance: 1 } }, // Always closest first for "nearest"
                { $skip: skipAmount },
                { $limit: pageSize },
                {
                    $project: {
                        _id: 1,
                        name: 1,
                        infoText: 1,
                        longitude: 1,
                        latitude: 1,
                        booksCount: 1,
                        image: 1,
                        owner: 1,
                        boroughId: 1,
                        isActive: 1,
                        distance: { $divide: ['$distance', 1000] } // Convert meters to km
                    }
                }
            ]);

            return nearbyBookboxes;
        }
    },

    async searchThreads(
        q?: string,
        cls: string = 'by recent activity',
        asc: boolean = true,
        limit: number = 20,
        page: number = 1
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;
        
        let filter: any = {};
        
        // Add search filter if q is provided
        if (q) {
            filter.$or = [
                { bookTitle: { $regex: q, $options: 'i' } },
                { title: { $regex: q, $options: 'i' } },
                { username: { $regex: q, $options: 'i' } }
            ];
        }
        
        if (cls === 'by recent activity') {
            // Use aggregation for sorting by last message timestamp
            return await Thread.aggregate([
                { $match: filter },
                {
                    $addFields: {
                        lastMessageTime: {
                            $cond: {
                                if: { $gt: [{ $size: '$messages' }, 0] },
                                then: { $arrayElemAt: ['$messages.timestamp', -1] },
                                else: new Date(0) // Very old date for threads with no messages
                            }
                        }
                    }
                },
                { $sort: { lastMessageTime: asc ? 1 : -1 } },
                { $skip: skipAmount },
                { $limit: pageSize },
                {
                    $project: {
                        _id: 1,
                        bookTitle: 1,
                        title: 1,
                        username: 1,
                        timestamp: 1,
                        messages: 1
                        // Remove lastMessageTime from final output
                    }
                }
            ]);
        } else if (cls === 'by number of messages') {
            // Use aggregation to sort by message count
            return await Thread.aggregate([
                { $match: filter },
                {
                    $addFields: {
                        messageCount: { $size: '$messages' }
                    }
                },
                { $sort: { messageCount: asc ? 1 : -1 } },
                { $skip: skipAmount },
                { $limit: pageSize },
                {
                    $project: {
                        _id: 1,
                        bookTitle: 1,
                        title: 1,
                        username: 1,
                        timestamp: 1,
                        messages: 1
                    }
                }
            ]);
        } else if (cls === 'by creation date') {
            // Simple sort by timestamp
            return await Thread.find(filter)
                .sort({ timestamp: asc ? 1 : -1 })
                .skip(skipAmount)
                .limit(pageSize)
                .lean();
        }
        
        // Default fallback
        return await Thread.find(filter)
            .skip(skipAmount)
            .limit(pageSize)
            .lean();
    },

    
    async searchMyManagedBookboxes(
        username: string,
        q: string | undefined,
        cls: string | undefined,
        asc: boolean | undefined,
        limit: number = 20,  
        page: number = 1   
    ) {
        // Get pagination parameters
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        // Build filter object
        let filter: any = { owner: username };
        if (q) {
            filter.name = { $regex: q, $options: 'i' };
        }
        
        // Build sort object
        let sort: any = {};
        if (cls === 'by name') {
            sort.name = asc ? 1 : -1;
        } else if (cls === 'by number of books') {
            sort.booksCount = asc ? 1 : -1; 
        }
        
        const bookboxes = await BookBox.find(filter)
            .sort(sort)
            .skip(skipAmount)
            .limit(pageSize);
            
        return bookboxes;
    },

    async searchTransactionHistory(
        username?: string,
        bookTitle?: string,
        bookboxId?: string,
        limit: number = 100,
        page: number = 1
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        let filter: any = {};
        if (username) filter.username = username;
        if (bookTitle) filter.bookTitle = new RegExp(bookTitle, 'i');
        if (bookboxId) filter.bookboxId = bookboxId;

        const transactions = await Transaction.find(filter)
            .sort({ timestamp: -1 })
            .skip(skipAmount)
            .limit(pageSize)
            .lean();

        return transactions;
    },

    
    async searchIssues(
        username?: string,
        bookboxId?: string,
        status?: string,
        oldestFirst: boolean = false,
        limit: number = 20,
        page: number = 1
    ) {
        const filter: any = {};
        if (username) filter.username = username;
        if (bookboxId) filter.bookboxId = bookboxId;
        if (status) filter.status = status;

        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        const issues = await Issue.find(filter)
            .sort({ 
                reportedAt: oldestFirst ? 1 : -1
            })
            .skip(skipAmount)
            .limit(pageSize);

        return issues;
    },

    async searchUsers(
        q?: string,
        limit: number = 10,
        page: number = 1
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;
        
        let filter: any = {};
        
        // Only add search filter if q is provided
        if (q) {
            const regex = new RegExp(q, 'i');
            filter.$or = [
                { username: regex },
                { email: regex }
            ];
        }
        
        const users = await User.find(filter)
            .skip(skipAmount) 
            .limit(pageSize)   
            .lean();

        return users.map(user => ({
            id: user._id.toString(),
            username: user.username,
            email: user.email,
        }));
}
}

export default searchService;