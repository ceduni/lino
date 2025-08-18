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
