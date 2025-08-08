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
    requestBookToUsers(id, title, customMessage) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const userBoroughIds = user.favouriteLocations.map(location => location.boroughId);
            const userFollowedBookboxes = user.followedBookboxes;
            if (userBoroughIds.length === 0 && userFollowedBookboxes.length === 0) {
                throw (0, utilities_1.newErr)(400, 'User has no favourite locations or followed bookboxes to notify');
            }
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
                            ...(userFollowedBookboxes.length > 0 ? [{
                                    followedBookboxes: { $in: userFollowedBookboxes }
                                }] : [])
                        ]
                    },
                    {
                        'notificationSettings.bookRequested': true
                    }
                ]
            });
            console.log(`Found ${usersToNotify.length} users to notify about the book request.`);
            // Notify all relevant users using the new notification system
            for (let i = 0; i < usersToNotify.length; i++) {
                if (usersToNotify[i].username !== user.username) {
                    yield _1.NotificationService.createNotification(usersToNotify[i]._id.toString(), ['book_request'], title);
                }
            }
            const newRequest = new models_1.Request({
                username: user.username,
                bookTitle: title,
                customMessage
            });
            yield newRequest.save();
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
    getBookRequests(username) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!username) {
                return models_1.Request.find();
            }
            else {
                return models_1.Request.find({ username: username });
            }
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
};
exports.default = RequestService;
