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

        // Get all bookboxes and filter by distance using Haversine formula
        const allBookboxes = await BookBox.find();
        const nearbyBookboxes = allBookboxes.filter(bookbox => {
            if (!bookbox.longitude || !bookbox.latitude) {
                return false;
            }
            
            const distance = this.calculateDistance(latitude, longitude, bookbox.latitude, bookbox.longitude);
            return distance <= user.requestNotificationRadius;
        });

        // Get all unique users who follow any of these nearby bookboxes
        const bookboxIds = nearbyBookboxes.map(bookbox => bookbox._id.toString());
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

    // Calculate distance between two points using Haversine formula
    calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
        const R = 6371; // Radius of the Earth in kilometers
        const dLat = this.deg2rad(lat2 - lat1);
        const dLon = this.deg2rad(lon2 - lon1);
        const a = 
            Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) * 
            Math.sin(dLon/2) * Math.sin(dLon/2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        const distance = R * c; // Distance in kilometers
        return distance;
    },

    // Convert degrees to radians
    deg2rad(deg: number): number {
        return deg * (Math.PI/180);
    }
};

export default requestService;
