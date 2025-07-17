import User from "../users/user.model";
import BookBox from "../bookboxes/bookbox.model";
import Request from "./book.request.model";
import NotificationService from "../notifications/notification.service";
import {newErr} from "../services/utilities";
import { AuthenticatedRequest } from '../types/common.types';

const RequestService = {
    async requestBookToUsers(request: AuthenticatedRequest & { 
        body: { title: string; customMessage?: string }; 
    }) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        const userBoroughIds = user.favouriteLocations.map(location => location.boroughId);
        const userFollowedBookboxes = user.followedBookboxes;

        if (userBoroughIds.length === 0 && userFollowedBookboxes.length === 0) {
            throw newErr(400, 'User has no favourite locations or followed bookboxes to notify');
        }

        // Find users who share favourite locations (by boroughId) or followed bookboxes
        const usersToNotify = await User.find({
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
        });
        
        console.log(`Found ${usersToNotify.length} users to notify about the book request.`);

        // Notify all relevant users using the new notification system
        for (let i = 0; i < usersToNotify.length; i++) {
            if (usersToNotify[i].username !== user.username) {
                await NotificationService.createNotification(
                    usersToNotify[i]._id.toString(),
                    ['book_request'],
                    request.body.title
                );
            }
        }

        const newRequest = new Request({
            username: user.username,
            bookTitle: request.body.title,
            customMessage: request.body.customMessage,
        });
        await newRequest.save();
        return newRequest;
    },

    async deleteBookRequest(request: { params: { id: string } }) {
        const requestId = request.params.id;
        const requestToDelete = await Request.findById(requestId);
        if (!requestToDelete) {
            throw newErr(404, 'Request not found');
        }
        await requestToDelete.deleteOne();
    },

    async getBookRequests(request: { query: { username?: string } }) {
        let username = request.query.username;
        if (!username) {
            return Request.find();
        } else {
            return Request.find({username: username});
        }
    },

    async toggleSolvedStatus(request: { params: { id: string } }) {
        const requestId = request.params.id;
        const bookRequest = await Request.findById(requestId);
        if (!bookRequest) {
            throw newErr(404, 'Request not found');
        }
        bookRequest.isSolved = !bookRequest.isSolved;
        await bookRequest.save();
        return {
            message: `Request ${bookRequest.isSolved ? 'solved' : 'unsolved'} successfully`,
            isSolved: bookRequest.isSolved
        };
    },
};

export default RequestService;
