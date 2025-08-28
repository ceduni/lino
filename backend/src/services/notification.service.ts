import { BookBox, User, Notification, Request } from '../models';
import { newErr, isFuzzyMatch } from '../utilities/utilities';
import { broadcastToUser } from '../index';
import { IBook } from '../types';
import { RequestService } from '.';

const NotificationService = {
    // Create a new notification
    async createNotification(
        userId: string, 
        reasons: string[], 
        bookTitle: string,
        options: {
            bookId?: string;
            bookboxId?: string;
            requestId?: string;
        } = {}
    ) {
        const notification = new Notification({
            userId,
            bookId: options.bookId,
            bookTitle: bookTitle,
            bookboxId: options.bookboxId,
            requestId: options.requestId,
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
                requestId: notification.requestId,
                reason: notification.reason,
                read: notification.read,
                createdAt: notification.createdAt
            }
        });

        return notification;
    },

    // Get user notifications (last 30 days)
    async getUserNotifications(id: string) {
        const userId = id;

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
    async readNotification(id: string, notificationId: string) {
        const userId = id;

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
        return await this.getUserNotifications(userId);
    },

    // Notify relevant users when a book is added to a bookbox
    async notifyRelevantUsers(excludedUsername: string, book: IBook, bookboxId: string) {
        const bookBox = await BookBox.findById(bookboxId);
        if (!bookBox) {
            throw newErr(404, 'Bookbox not found');
        }

        // Find all requests that fuzzy match the book's title
        const allRequests = await Request.find();
        const matchingRequests = allRequests.filter(request => 
            isFuzzyMatch(request.bookTitle, book.title, 0.8)
        );
        console.log('Matching requests:', matchingRequests);

        // Get all users who upvoted matching requests
        const upvoterUsernames = new Set<string>();
        const requestIdsByUpvoter = new Map<string, string>();

        for (const request of matchingRequests) {
            for (const upvoterUsername of request.upvoters) {
                if (upvoterUsername !== excludedUsername) {
                    upvoterUsernames.add(upvoterUsername);
                    requestIdsByUpvoter.set(upvoterUsername, request._id.toString());
                }
            }
        }

        // Get user objects for all upvoters
        const upvoterUsers = await User.find({ 
            username: { $in: Array.from(upvoterUsernames) },
            'notificationSettings.addedBook': true
        });

        console.log('UpvoterUsers:', upvoterUsers);

        // Notify each upvoter
        for (const user of upvoterUsers) {
            const reasons: string[] = ['solved_book_request'];
            
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
            
            const notificationOptions: any = {
                bookboxId: bookboxId,
                requestId: requestIdsByUpvoter.get(user.username)
            };
            
            // Only include bookId if it exists and is not empty
            if (book._id && book._id.toString()) {
                notificationOptions.bookId = book._id.toString();
            }
            
            await this.createNotification(
                user._id.toString(),
                reasons,
                book.title,
                notificationOptions
            );
        }

        // Also notify users based on other criteria (bookbox followers, location, genre) who didn't upvote
        const users = await User.find({
            username: { $nin: [excludedUsername, ...Array.from(upvoterUsernames)] },
            'notificationSettings.addedBook': true
        });
        
        for (const user of users) {
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

            // Create notification if there's at least a reason related to the book box
            if (reasons.length > 0) {
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
                
                const notificationOptions: any = {
                    bookboxId: bookboxId
                };
                
                // Only include bookId if it exists and is not empty
                if (book._id && book._id.toString()) {
                    notificationOptions.bookId = book._id.toString();
                }
                
                await this.createNotification(
                    user._id.toString(),
                    reasons,
                    book.title,
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
