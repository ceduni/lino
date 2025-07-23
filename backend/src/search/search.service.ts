import BookBox from "../bookboxes/bookbox.model";
import Issue from "../issues/issue.model";
import { getBoroughId } from "../services/borough.id.generator";
import { newErr } from "../services/utilities";
import Thread from "../threads/thread.model";
import Transaction from "../transactions/transaction.model";
import User from "../users/user.model";

const searchService = {
    async searchBooks(
        q?: string,
        cls: string = 'by title',
        asc: boolean = true,
        limit: number = 20,
        page: number = 1
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        // Build the base pipeline (without skip/limit for counting)
        const basePipeline: any[] = [
            { $match: {} },
            { $unwind: '$books' },
            {
                $addFields: {
                    'books.bookboxId': { $toString: '$_id' },
                    'books.bookboxName': '$name'
                }
            }
        ];

        // Add search filter if provided
        if (q) {
            basePipeline.push({
                $match: {
                    $or: [
                        { 'books.title': { $regex: q, $options: 'i' } },
                        { 'books.authors': { $regex: q, $options: 'i' } },
                        { 'books.categories': { $regex: q, $options: 'i' } }
                    ]
                }
            });
        }

        // Create pipelines for data and count
        const dataPipeline = [...basePipeline];
        const countPipeline = [...basePipeline, { $count: "total" }];

        // Add sorting and pagination to data pipeline
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

        dataPipeline.push({ $sort: { [sortField]: sortOrder } });
        dataPipeline.push({ $skip: skipAmount });
        dataPipeline.push({ $limit: pageSize });

        // Project the final structure
        dataPipeline.push({
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

        // Execute both pipelines
        const [books, countResult] = await Promise.all([
            BookBox.aggregate(dataPipeline),
            BookBox.aggregate(countPipeline)
        ]);

        const total = countResult[0]?.total || 0;
        const totalPages = Math.ceil(total / pageSize);

        return {
            books,
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
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

        let filter: any = { };
        
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
            
            // For $geoNear, we need to get count differently
            const [bookboxes, countResult] = await Promise.all([
                BookBox.aggregate([
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
                ]),
                // Count for location queries
                BookBox.aggregate([
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
                    { $count: "total" }
                ])
            ]);

            const total = countResult[0]?.total || 0;
            const totalPages = Math.ceil(total / pageSize);

            return {
                bookboxes,
                pagination: {
                    currentPage: page,
                    totalPages,
                    totalResults: total,
                    hasNextPage: page < totalPages,
                    hasPrevPage: page > 1,
                    limit: pageSize
                }
            };
        }
        
        // Handle other sorting with regular query + count
        let sortObj: any = {};
        if (cls === 'by name') {
            sortObj.name = asc ? 1 : -1;
        } else if (cls === 'by number of books') {
            sortObj.booksCount = asc ? 1 : -1;
        }

        const [bookboxes, total] = await Promise.all([
            BookBox.find(filter)
                .sort(sortObj)
                .skip(skipAmount)
                .limit(pageSize)
                .select('_id name infoText longitude latitude booksCount image owner boroughId isActive')
                .lean(),
            BookBox.countDocuments(filter)
        ]);

        const totalPages = Math.ceil(total / pageSize);

        return {
            bookboxes,
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
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
            
            const filter = { 
                boroughId: locationBoroughId, 
            };

            // Find bookboxes in the same borough with count
            const [bookboxes, total] = await Promise.all([
                BookBox.find(filter)
                    .skip(skipAmount)
                    .limit(pageSize)
                    .select('_id name infoText longitude latitude booksCount image owner boroughId isActive')
                    .lean(),
                BookBox.countDocuments(filter)
            ]);

            const totalPages = Math.ceil(total / pageSize);

            return {
                bookboxes,
                pagination: {
                    currentPage: page,
                    totalPages,
                    totalResults: total,
                    hasNextPage: page < totalPages,
                    hasPrevPage: page > 1,
                    limit: pageSize
                }
            };
        } else {
            // Use $geoNear for accurate distance calculation
            const [nearbyBookboxes, countResult] = await Promise.all([
                BookBox.aggregate([
                    {
                        $geoNear: {
                            near: { 
                                type: 'Point', 
                                coordinates: [longitude, latitude] 
                            },
                            distanceField: 'distance',
                            maxDistance: maxDistance * 1000, // Convert km to meters
                            spherical: true,
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
                ]),
                // Count nearby bookboxes within distance
                BookBox.aggregate([
                    {
                        $geoNear: {
                            near: { 
                                type: 'Point', 
                                coordinates: [longitude, latitude] 
                            },
                            distanceField: 'distance',
                            maxDistance: maxDistance * 1000,
                            spherical: true,
                        }
                    },
                    { $count: "total" }
                ])
            ]);

            const total = countResult[0]?.total || 0;
            const totalPages = Math.ceil(total / pageSize);

            return {
                bookboxes: nearbyBookboxes,
                pagination: {
                    currentPage: page,
                    totalPages,
                    totalResults: total,
                    hasNextPage: page < totalPages,
                    hasPrevPage: page > 1,
                    limit: pageSize
                }
            };
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
            const [threads, countResult] = await Promise.all([
                Thread.aggregate([
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
                        }
                    }
                ]),
                // Count for recent activity
                Thread.aggregate([
                    { $match: filter },
                    { $count: "total" }
                ])
            ]);

            const total = countResult[0]?.total || 0;
            const totalPages = Math.ceil(total / pageSize);

            return {
                threads,
                pagination: {
                    currentPage: page,
                    totalPages,
                    totalResults: total,
                    hasNextPage: page < totalPages,
                    hasPrevPage: page > 1,
                    limit: pageSize
                }
            };
        } else if (cls === 'by number of messages') {
            // Use aggregation to sort by message count
            const [threads, countResult] = await Promise.all([
                Thread.aggregate([
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
                ]),
                // Count for message count sorting
                Thread.aggregate([
                    { $match: filter },
                    { $count: "total" }
                ])
            ]);

            const total = countResult[0]?.total || 0;
            const totalPages = Math.ceil(total / pageSize);

            return {
                threads,
                pagination: {
                    currentPage: page,
                    totalPages,
                    totalResults: total,
                    hasNextPage: page < totalPages,
                    hasPrevPage: page > 1,
                    limit: pageSize
                }
            };
        } else if (cls === 'by creation date') {
            // Simple sort by timestamp with count
            const [threads, total] = await Promise.all([
                Thread.find(filter)
                    .sort({ timestamp: asc ? 1 : -1 })
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                Thread.countDocuments(filter)
            ]);

            const totalPages = Math.ceil(total / pageSize);

            return {
                threads,
                pagination: {
                    currentPage: page,
                    totalPages,
                    totalResults: total,
                    hasNextPage: page < totalPages,
                    hasPrevPage: page > 1,
                    limit: pageSize
                }
            };
        }
        
        // Default fallback with count
        const [threads, total] = await Promise.all([
            Thread.find(filter)
                .skip(skipAmount)
                .limit(pageSize)
                .lean(),
            Thread.countDocuments(filter)
        ]);

        const totalPages = Math.ceil(total / pageSize);

        return {
            threads,
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
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
        
        const [bookboxes, total] = await Promise.all([
            BookBox.find(filter)
                .sort(sort)
                .skip(skipAmount)
                .limit(pageSize)
                .lean(),
            BookBox.countDocuments(filter)
        ]);

        const totalPages = Math.ceil(total / pageSize);
            
        return {
            bookboxes,
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
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

        const [transactions, total] = await Promise.all([
            Transaction.find(filter)
                .sort({ timestamp: -1 })
                .skip(skipAmount)
                .limit(pageSize)
                .lean(),
            Transaction.countDocuments(filter)
        ]);

        const totalPages = Math.ceil(total / pageSize);

        return {
            transactions,
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
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

        const [issues, total] = await Promise.all([
            Issue.find(filter)
                .sort({ 
                    reportedAt: oldestFirst ? 1 : -1
                })
                .skip(skipAmount)
                .limit(pageSize)
                .lean(),
            Issue.countDocuments(filter)
        ]);

        const totalPages = Math.ceil(total / pageSize);

        return {
            issues,
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
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
        
        const [users, total] = await Promise.all([
            User.find(filter)
                .skip(skipAmount) 
                .limit(pageSize)   
                .lean(),
            User.countDocuments(filter)
        ]);

        const totalPages = Math.ceil(total / pageSize);

        return {
            users: users.map(user => ({
                _id: user._id.toString(),
                username: user.username,
                email: user.email,
                isAdmin: user.isAdmin,
            })),
            pagination: {
                currentPage: page,
                totalPages,
                totalResults: total,
                hasNextPage: page < totalPages,
                hasPrevPage: page > 1,
                limit: pageSize
            }
        };
    }
}

export default searchService;