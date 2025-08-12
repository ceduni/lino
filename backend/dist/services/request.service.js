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
const _1 = require(".");
const utilities_1 = require("../utilities/utilities");
const RequestService = {
    requestBookToUsers(userId_1, title_1) {
        return __awaiter(this, arguments, void 0, function* (userId, title, bookboxIds = [], customMessage) {
            const user = yield models_1.User.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const newRequest = new models_1.Request({
                username: user.username,
                bookTitle: title,
                bookboxIds: bookboxIds || [],
                customMessage,
                upvoters: [userId]
            });
            yield newRequest.save();
            const userBoroughIds = user.favouriteLocations.map(location => location.boroughId);
            // Find users who share favourite locations (by boroughId) or followed bookboxes
            const usersToNotify = yield models_1.User.find({
                $and: [
                    {
                        $or: [
                            // Users who have favourite locations with matching boroughIds
                            ...(userBoroughIds.length > 0 ? [{
                                    'favouriteLocations.boroughId': { $in: userBoroughIds }
                                }] : []),
                            // Users who follow at least one of the same bookboxes
                            ...(bookboxIds.length > 0 ? [{
                                    followedBookboxes: { $in: bookboxIds }
                                }] : [])
                        ]
                    },
                    {
                        'notificationSettings.bookRequested': true
                    }
                ]
            });
            console.log(`Found ${usersToNotify.length} users to notify about the book request.`);
            // Update the number of people notified by the request
            newRequest.nbPeopleNotified = usersToNotify.length;
            yield newRequest.save();
            // Notify all relevant users using the new notification system
            for (let i = 0; i < usersToNotify.length; i++) {
                if (usersToNotify[i].username !== user.username) {
                    yield _1.NotificationService.createNotification(usersToNotify[i]._id.toString(), ['book_request'], title, {
                        requestId: newRequest._id.toString()
                    });
                }
            }
            return newRequest;
        });
    },
    deleteBookRequest(id) {
        return __awaiter(this, void 0, void 0, function* () {
            const requestToDelete = yield models_1.Request.findById(id);
            if (!requestToDelete) {
                throw (0, utilities_1.newErr)(404, 'Request not found');
            }
            yield requestToDelete.deleteOne();
        });
    },
    getBookRequests(username_1) {
        return __awaiter(this, arguments, void 0, function* (username, options = {}) {
            const { filter = 'all', sortBy = 'date', sortOrder = 'desc', userId } = options;
            let query = {};
            // Apply username filter if provided
            if (username) {
                query.username = username;
            }
            // Apply specific filters based on user interactions
            if (filter === 'notified' && userId) {
                // Get notifications for this user that have 'book_request' in reasons
                const notifications = yield models_1.Notification.find({
                    userId: userId,
                    reason: { $in: ['book_request'] },
                    requestId: { $exists: true, $ne: null }
                });
                const requestIds = notifications.map(notification => notification.requestId);
                query._id = { $in: requestIds };
            }
            else if (filter === 'upvoted' && userId) {
                // Find user object to get username
                const user = yield models_1.User.findById(userId);
                if (user) {
                    query.upvoters = { $in: [user.username] };
                }
                else {
                    // If user not found, return empty result
                    return [];
                }
            }
            else if (filter === 'mine' && userId) {
                // Get user's own requests
                const user = yield models_1.User.findById(userId);
                if (user) {
                    query.username = user.username;
                }
                else {
                    // If user not found, return empty result
                    return [];
                }
            }
            // Build the base query
            let requestQuery = models_1.Request.find(query);
            // Apply sorting
            let sortOptions = {};
            switch (sortBy) {
                case 'date':
                    sortOptions.timestamp = sortOrder === 'asc' ? 1 : -1;
                    break;
                case 'upvoters':
                    // Sort by number of upvoters (length of upvoters array)
                    const aggregationPipeline = [
                        { $match: query },
                        {
                            $addFields: {
                                upvotersCount: { $size: "$upvoters" }
                            }
                        },
                        {
                            $sort: {
                                upvotersCount: (sortOrder === 'asc' ? 1 : -1)
                            }
                        }
                    ];
                    return yield models_1.Request.aggregate(aggregationPipeline);
                case 'peopleNotified':
                    sortOptions.nbPeopleNotified = sortOrder === 'asc' ? 1 : -1;
                    break;
                default:
                    sortOptions.timestamp = -1; // Default to newest first
            }
            return yield requestQuery.sort(sortOptions);
        });
    },
    toggleSolvedStatus(id) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookRequest = yield models_1.Request.findById(id);
            if (!bookRequest) {
                throw (0, utilities_1.newErr)(404, 'Request not found');
            }
            bookRequest.isSolved = !bookRequest.isSolved;
            yield bookRequest.save();
            return {
                message: `Request ${bookRequest.isSolved ? 'solved' : 'unsolved'} successfully`,
                isSolved: bookRequest.isSolved
            };
        });
    },
    toggleUpvote(requestId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const bookRequest = yield models_1.Request.findById(requestId);
            if (!bookRequest) {
                throw (0, utilities_1.newErr)(404, 'Request not found');
            }
            const user = yield models_1.User.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const username = user.username;
            const upvoterIndex = bookRequest.upvoters.indexOf(username);
            let isUpvoted;
            let message;
            if (upvoterIndex > -1) {
                // User has already upvoted, remove the upvote
                bookRequest.upvoters.splice(upvoterIndex, 1);
                isUpvoted = false;
                message = 'Upvote removed successfully';
            }
            else {
                // User hasn't upvoted, add the upvote
                bookRequest.upvoters.push(username);
                isUpvoted = true;
                message = 'Request upvoted successfully';
            }
            yield bookRequest.save();
            return {
                message,
                isUpvoted,
                upvoteCount: bookRequest.upvoters.length,
                request: bookRequest
            };
        });
    },
};
exports.default = RequestService;
