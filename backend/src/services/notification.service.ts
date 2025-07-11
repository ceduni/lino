import Notification from '../models/notification.model';
import User from '../models/user.model';
import BookBox from '../models/bookbox.model';
import { newErr } from './utilities';
import { broadcastToUser } from '../index';
import { AuthenticatedRequest } from '../types/common.types';
import { IBook } from '../types/book.types';

const NotificationService = {
    // Create a new notification
    async createNotification(
        userId: string, 
        reasons: string[], 
        options: {
            bookId?: string;
            bookTitle?: string;
            bookboxId?: string;
        } = {}
    ) {
        const notification = new Notification({
            userId,
            bookId: options.bookId,
            bookTitle: options.bookTitle,
            bookboxId: options.bookboxId,
            reason: reasons,
            read: false
        });

        await notification.save();

        // Broadcast the notification to the user if they are connected via WebSocket
        broadcastToUser(userId, { 
            event: 'newNotification', 
            data: {
                _id: notification._id,
                userId: notification.userId,
                bookId: notification.bookId,
                bookTitle: notification.bookTitle,
                bookboxId: notification.bookboxId,
                reason: notification.reason,
                read: notification.read,
                createdAt: notification.createdAt
            }
        });

        return notification;
    },

    // Get user notifications (last 30 days)
    async getUserNotifications(request: AuthenticatedRequest) {
        const userId = request.user.id;
        
        // Calculate the date 30 days ago
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const notifications = await Notification.find({
            userId: userId,
            createdAt: { $gte: thirtyDaysAgo }
        }).sort({ createdAt: -1 });

        return notifications;
    },

    // Mark a notification as read
    async readNotification(request: AuthenticatedRequest & { body: { notificationId: string } }) {
        const userId = request.user.id;
        const notificationId = request.body.notificationId; 

        const notification = await Notification.findOne({
            _id: notificationId,
            userId: userId
        });

        if (!notification) {
            throw newErr(404, 'Notification not found');
        }

        notification.read = true;
        await notification.save();

        // Return all user notifications after marking as read
        return await this.getUserNotifications(request);
    },

    // Notify relevant users when a book is added to a bookbox
    async notifyRelevantUsers(username: string, book: IBook, bookboxId: string) {
        const bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }

        const users = await User.find();
        
        for (const user of users) {
            if (user.username === username) {
                continue; // Skip the user who added the book
            }

            const reasons: string[] = [];

            // Check if user follows this bookbox
            if (user.followedBookboxes.includes(bookboxId)) {
                reasons.push('fav_bookbox');
            }

            // Check if the borough matches one of the user's favourite locations
            for (const location of user.favouriteLocations) {
                if (location.boroughId === bookBox.boroughId) {
                    reasons.push('same_borough');
                    break; // Exit early since we only need to find one match
                }
            }

            // Check if book categories match user's favourite genres
            if (user.favouriteGenres && user.favouriteGenres.length > 0 && book.categories) {
                const hasMatchingGenre = book.categories.some(category => 
                    user.favouriteGenres.some(genre => 
                        genre.toLowerCase() === category.toLowerCase()
                    )
                );
                if (hasMatchingGenre) {
                    reasons.push('fav_genre');
                }
            }

            // Create notification if at least one reason exists
            if (reasons.length > 0) {
                const notificationOptions: any = {
                    bookTitle: book.title || '',
                    bookboxId: bookboxId
                };
                
                // Only include bookId if it exists and is not empty
                if (book._id && book._id.toString()) {
                    notificationOptions.bookId = book._id.toString();
                }
                
                await this.createNotification(
                    user._id.toString(),
                    reasons,
                    notificationOptions
                );
            }
        }
    },

    // Clear all notifications (for testing/admin purposes)
    async clearCollection() {
        await Notification.deleteMany({});
    }
};

export default NotificationService;
