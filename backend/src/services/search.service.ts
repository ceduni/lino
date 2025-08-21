import { BookBox, Issue, Thread, Transaction, User, Request, Notification } from "../models";
import { getBoroughId } from "../utilities/borough.id.generator";
import { newErr } from "../utilities/utilities";

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
        
        // Check if location is required for 'by location' classification
        if (cls === 'by location' && (!longitude || !latitude)) {
            throw newErr(400, 'Location is required for this classification');
        }
        
        // If coordinates are provided, use $geoNear to include distance for all classifications
        if (longitude && latitude) {
            let sortStage: any;
            
            if (cls === 'by location') {
                sortStage = { $sort: { distance: asc ? 1 : -1 } };
            } else if (cls === 'by name') {
                sortStage = { $sort: { name: asc ? 1 : -1 } };
            } else if (cls === 'by number of books') {
                sortStage = { $sort: { booksCount: asc ? 1 : -1 } };
            } else {
                sortStage = { $sort: { name: asc ? 1 : -1 } }; // default sort
            }
            
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
                    sortStage,
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
                // Count for queries with coordinates
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
        
        // Handle sorting without coordinates (no distance field)
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
        let filter: any = {};

        // Only filter by owner if not admin
        if (username !== process.env.ADMIN_USERNAME) filter.owner = username;

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
        isbn?: string,
        bookboxId?: string,
        limit: number = 100,
        page: number = 1
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;

        let filter: any = {};
        if (username) filter.username = username;
        if (isbn) filter.isbn = new RegExp(isbn, 'i');
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
    },

    async searchBookRequests(
        q?: string,
        filter: 'all' | 'notified' | 'upvoted' | 'mine' = 'all',
        sortBy: 'date' | 'upvoters' | 'peopleNotified' = 'date',
        sortOrder: 'asc' | 'desc' = 'desc',
        userId?: string,
        limit: number = 20,
        page: number = 1
    ) {
        const pageSize = limit;
        const skipAmount = (page - 1) * pageSize;
        
        // Restrict certain filters to authenticated users only
        if (!userId && ['notified', 'upvoted', 'mine'].includes(filter)) {
            throw newErr(401, 'Authentication required for this filter');
        }
        
        let query: any = {};
        
        // Add search filter if q is provided
        if (q) {
            query.bookTitle = { $regex: q, $options: 'i' };
        }
        
        // Apply specific filters based on user interactions
        if (filter === 'notified' && userId) {
            // Get notifications for this user that have 'book_request' in reasons
            const notifications = await Notification.find({
                userId: userId,
                reason: { $in: ['book_request'] },
                requestId: { $exists: true, $ne: null }
            });
            
            const requestIds = notifications.map(notification => notification.requestId);
            query._id = { $in: requestIds };
            
        } else if (filter === 'upvoted' && userId) {
            // Find user object to get username
            const user = await User.findById(userId);
            if (user) {
                query.upvoters = { $in: [user.username] };
            } else {
                // If user not found, return empty result
                return {
                    requests: [],
                    pagination: {
                        currentPage: page,
                        totalPages: 0,
                        totalResults: 0,
                        hasNextPage: false,
                        hasPrevPage: false,
                        limit: pageSize
                    }
                };
            }
        } else if (filter === 'mine' && userId) {
            // Get user's own requests
            const user = await User.findById(userId);
            if (user) {
                query.username = user.username;
            } else {
                // If user not found, return empty result
                return {
                    requests: [],
                    pagination: {
                        currentPage: page,
                        totalPages: 0,
                        totalResults: 0,
                        hasNextPage: false,
                        hasPrevPage: false,
                        limit: pageSize
                    }
                };
            }
        }
        // For 'all' filter or non-authenticated users, no additional query filters are applied
        
        // Handle sorting
        if (sortBy === 'upvoters') {
            // Use aggregation for sorting by number of upvoters
            const aggregationPipeline = [
                { $match: query },
                {
                    $addFields: {
                        upvotersCount: { $size: "$upvoters" }
                    }
                },
                {
                    $sort: {
                        upvotersCount: (sortOrder === 'asc' ? 1 : -1) as 1 | -1
                    }
                },
                { $skip: skipAmount },
                { $limit: pageSize }
            ];

            const countPipeline = [
                { $match: query },
                { $count: "total" }
            ];

            const [requests, countResult] = await Promise.all([
                Request.aggregate(aggregationPipeline),
                Request.aggregate(countPipeline)
            ]);

            const total = countResult[0]?.total || 0;
            const totalPages = Math.ceil(total / pageSize);

            return {
                requests,
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
            // Use regular find with sorting for other sort options
            let sortOptions: any = {};
            
            switch (sortBy) {
                case 'date':
                    sortOptions.timestamp = sortOrder === 'asc' ? 1 : -1;
                    break;
                case 'peopleNotified':
                    sortOptions.nbPeopleNotified = sortOrder === 'asc' ? 1 : -1;
                    break;
                default:
                    sortOptions.timestamp = -1; // Default to newest first
            }

            const [requests, total] = await Promise.all([
                Request.find(query)
                    .sort(sortOptions)
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                Request.countDocuments(query)
            ]);

            const totalPages = Math.ceil(total / pageSize);

            return {
                requests,
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
}

export default searchService;
