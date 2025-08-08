"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const models_1 = require("../models");
const borough_id_generator_1 = require("../utilities/borough.id.generator");
const utilities_1 = require("../utilities/utilities");
const searchService = {
    searchBooks(q_1) {
        return __awaiter(this, arguments, void 0, function* (q, cls = 'by title', asc = true, limit = 20, page = 1) {
            var _a;
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            // Build the base pipeline (without skip/limit for counting)
            const basePipeline = [
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
            let sortField;
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
            const [books, countResult] = yield Promise.all([
                models_1.BookBox.aggregate(dataPipeline),
                models_1.BookBox.aggregate(countPipeline)
            ]);
            const total = ((_a = countResult[0]) === null || _a === void 0 ? void 0 : _a.total) || 0;
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
        });
    },
    searchBookboxes(q_1) {
        return __awaiter(this, arguments, void 0, function* (q, cls = 'by name', asc = true, longitude, latitude, limit = 20, page = 1) {
            var _a;
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            let filter = {};
            if (q) {
                filter.$or = [
                    { name: { $regex: q, $options: 'i' } },
                    { infoText: { $regex: q, $options: 'i' } }
                ];
            }
            // Handle location sorting with $geoNear
            if (cls === 'by location') {
                if (!longitude || !latitude) {
                    throw (0, utilities_1.newErr)(400, 'Location is required for this classification');
                }
                // For $geoNear, we need to get count differently
                const [bookboxes, countResult] = yield Promise.all([
                    models_1.BookBox.aggregate([
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
                    models_1.BookBox.aggregate([
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
                const total = ((_a = countResult[0]) === null || _a === void 0 ? void 0 : _a.total) || 0;
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
            let sortObj = {};
            if (cls === 'by name') {
                sortObj.name = asc ? 1 : -1;
            }
            else if (cls === 'by number of books') {
                sortObj.booksCount = asc ? 1 : -1;
            }
            const [bookboxes, total] = yield Promise.all([
                models_1.BookBox.find(filter)
                    .sort(sortObj)
                    .skip(skipAmount)
                    .limit(pageSize)
                    .select('_id name infoText longitude latitude booksCount image owner boroughId isActive')
                    .lean(),
                models_1.BookBox.countDocuments(filter)
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
        });
    },
    findNearestBookboxes(longitude_1, latitude_1) {
        return __awaiter(this, arguments, void 0, function* (longitude, latitude, maxDistance = 5, searchByBorough = false, limit = 20, page = 1) {
            var _a;
            if (!longitude || !latitude) {
                throw (0, utilities_1.newErr)(400, 'Longitude and latitude are required');
            }
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            if (searchByBorough) {
                // Get borough ID first
                const locationBoroughId = yield (0, borough_id_generator_1.getBoroughId)(latitude, longitude);
                const filter = {
                    boroughId: locationBoroughId,
                };
                // Find bookboxes in the same borough with count
                const [bookboxes, total] = yield Promise.all([
                    models_1.BookBox.find(filter)
                        .skip(skipAmount)
                        .limit(pageSize)
                        .select('_id name infoText longitude latitude booksCount image owner boroughId isActive')
                        .lean(),
                    models_1.BookBox.countDocuments(filter)
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
            }
            else {
                // Use $geoNear for accurate distance calculation
                const [nearbyBookboxes, countResult] = yield Promise.all([
                    models_1.BookBox.aggregate([
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
                    models_1.BookBox.aggregate([
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
                const total = ((_a = countResult[0]) === null || _a === void 0 ? void 0 : _a.total) || 0;
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
        });
    },
    searchThreads(q_1) {
        return __awaiter(this, arguments, void 0, function* (q, cls = 'by recent activity', asc = true, limit = 20, page = 1) {
            var _a, _b;
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            let filter = {};
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
                const [threads, countResult] = yield Promise.all([
                    models_1.Thread.aggregate([
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
                    models_1.Thread.aggregate([
                        { $match: filter },
                        { $count: "total" }
                    ])
                ]);
                const total = ((_a = countResult[0]) === null || _a === void 0 ? void 0 : _a.total) || 0;
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
            else if (cls === 'by number of messages') {
                // Use aggregation to sort by message count
                const [threads, countResult] = yield Promise.all([
                    models_1.Thread.aggregate([
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
                    models_1.Thread.aggregate([
                        { $match: filter },
                        { $count: "total" }
                    ])
                ]);
                const total = ((_b = countResult[0]) === null || _b === void 0 ? void 0 : _b.total) || 0;
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
            else if (cls === 'by creation date') {
                // Simple sort by timestamp with count
                const [threads, total] = yield Promise.all([
                    models_1.Thread.find(filter)
                        .sort({ timestamp: asc ? 1 : -1 })
                        .skip(skipAmount)
                        .limit(pageSize)
                        .lean(),
                    models_1.Thread.countDocuments(filter)
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
            const [threads, total] = yield Promise.all([
                models_1.Thread.find(filter)
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                models_1.Thread.countDocuments(filter)
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
        });
    },
    searchMyManagedBookboxes(username_1, q_1, cls_1, asc_1) {
        return __awaiter(this, arguments, void 0, function* (username, q, cls, asc, limit = 20, page = 1) {
            // Get pagination parameters
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            // Build filter object
            let filter = {};
            // Only filter by owner if not admin
            if (username !== process.env.ADMIN_USERNAME)
                filter.owner = username;
            if (q) {
                filter.name = { $regex: q, $options: 'i' };
            }
            // Build sort object
            let sort = {};
            if (cls === 'by name') {
                sort.name = asc ? 1 : -1;
            }
            else if (cls === 'by number of books') {
                sort.booksCount = asc ? 1 : -1;
            }
            const [bookboxes, total] = yield Promise.all([
                models_1.BookBox.find(filter)
                    .sort(sort)
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                models_1.BookBox.countDocuments(filter)
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
        });
    },
    searchTransactionHistory(username_1, bookTitle_1, bookboxId_1) {
        return __awaiter(this, arguments, void 0, function* (username, bookTitle, bookboxId, limit = 100, page = 1) {
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            let filter = {};
            if (username)
                filter.username = username;
            if (bookTitle)
                filter.bookTitle = new RegExp(bookTitle, 'i');
            if (bookboxId)
                filter.bookboxId = bookboxId;
            const [transactions, total] = yield Promise.all([
                models_1.Transaction.find(filter)
                    .sort({ timestamp: -1 })
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                models_1.Transaction.countDocuments(filter)
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
        });
    },
    searchIssues(username_1, bookboxId_1, status_1) {
        return __awaiter(this, arguments, void 0, function* (username, bookboxId, status, oldestFirst = false, limit = 20, page = 1) {
            const filter = {};
            if (username)
                filter.username = username;
            if (bookboxId)
                filter.bookboxId = bookboxId;
            if (status)
                filter.status = status;
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            const [issues, total] = yield Promise.all([
                models_1.Issue.find(filter)
                    .sort({
                    reportedAt: oldestFirst ? 1 : -1
                })
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                models_1.Issue.countDocuments(filter)
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
        });
    },
    searchUsers(q_1) {
        return __awaiter(this, arguments, void 0, function* (q, limit = 10, page = 1) {
            const pageSize = limit;
            const skipAmount = (page - 1) * pageSize;
            let filter = {};
            // Only add search filter if q is provided
            if (q) {
                const regex = new RegExp(q, 'i');
                filter.$or = [
                    { username: regex },
                    { email: regex }
                ];
            }
            const [users, total] = yield Promise.all([
                models_1.User.find(filter)
                    .skip(skipAmount)
                    .limit(pageSize)
                    .lean(),
                models_1.User.countDocuments(filter)
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
        });
    }
};
exports.default = searchService;
