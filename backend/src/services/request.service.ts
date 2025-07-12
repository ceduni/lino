import User from "../models/user.model";
import BookBox from "../models/bookbox.model";
import Request from "../models/book.request.model";
import NotificationService from "./notification.service";
import {newErr} from "./utilities";
import { AuthenticatedRequest } from '../types/common.types';

const requestService = {
    async requestBookToUsers(request: AuthenticatedRequest & { 
        body: { title: string; customMessage?: string }; 
        query: { latitude?: number; longitude?: number } 
    }) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        const { latitude, longitude } = request.query;
        if (!latitude || !longitude) {
            throw newErr(400, 'User location (latitude and longitude) is required');
        }

        const userBoroughIds = user.favouriteLocations.map(location => location.boroughId);
        if (userBoroughIds.length === 0) {
            throw newErr(400, 'User has no favourite locations to notify');
        }

        // Get all bookboxes and filter 
        const allBookboxes = await BookBox.find();
        const favBookboxes = allBookboxes.filter(bookbox => {
            // Get book boxes whose boroughId is in user's favourite locations
            if (!userBoroughIds.includes(bookbox.boroughId)) {
                return false;
            }
        });

        // Get all unique users who follow any of these nearby bookboxes
        const bookboxIds = favBookboxes.map(bookbox => bookbox._id.toString());
        console.log(`bookboxIds: ${bookboxIds}`);
        const usersToNotify = await User.find({
            followedBookboxes: { $in: bookboxIds }
        }); 
        console.log(`Found ${usersToNotify.length} users to notify about the book request.`);

        // Notify all relevant users using the new notification system
        for (let i = 0; i < usersToNotify.length; i++) {
            if (usersToNotify[i].username !== user.username) {
                await NotificationService.createNotification(
                    usersToNotify[i]._id.toString(),
                    ['book_request'],
                    {
                        bookTitle: request.body.title
                    }
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
};

export default requestService;
