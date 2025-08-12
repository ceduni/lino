import { User, Request, Notification } from "../models";
import { NotificationService } from ".";
import { newErr } from "../utilities/utilities";

const RequestService = {
    async requestBookToUsers(
        userId: string,
        title: string,
        bookboxIds: string[] = [],
        customMessage?: string
    ) {
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        const newRequest = new Request({
            username: user.username,
            bookTitle: title,
            bookboxIds: bookboxIds || [],
            customMessage,
            upvoters: [userId]
        });
        await newRequest.save();

        const userBoroughIds = user.favouriteLocations.map(location => location.boroughId);

        // Find users who share favourite locations (by boroughId) or followed bookboxes
        const usersToNotify = await User.find({
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
        await newRequest.save();

        // Notify all relevant users using the new notification system
        for (let i = 0; i < usersToNotify.length; i++) {
            if (usersToNotify[i].username !== user.username) {
                await NotificationService.createNotification(
                    usersToNotify[i]._id.toString(),
                    ['book_request'],
                    title,
                    {
                        requestId: newRequest._id.toString()
                    }
                );
            }
        }
        return newRequest;
    },

    async deleteBookRequest(id: string) {
        const requestToDelete = await Request.findById(id);
        if (!requestToDelete) {
            throw newErr(404, 'Request not found');
        }
        await requestToDelete.deleteOne();
    },

    async getBookRequests(
        username?: string,
        options: {
            filter?: 'all' | 'notified' | 'upvoted' | 'mine';
            sortBy?: 'date' | 'upvoters' | 'peopleNotified';
            sortOrder?: 'asc' | 'desc';
            userId?: string; // Required for 'notified', 'upvoted', and 'mine' filters
        } = {}
    ) {
        const { filter = 'all', sortBy = 'date', sortOrder = 'desc', userId } = options;
        
        let query: any = {};
        
        // Apply username filter if provided
        if (username) {
            query.username = username;
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
                return [];
            }
        } else if (filter === 'mine' && userId) {
            // Get user's own requests
            const user = await User.findById(userId);
            if (user) {
                query.username = user.username;
            } else {
                // If user not found, return empty result
                return [];
            }
        }
        
        // Build the base query
        let requestQuery = Request.find(query);
        
        // Apply sorting
        let sortOptions: any = {};
        
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
                            upvotersCount: (sortOrder === 'asc' ? 1 : -1) as 1 | -1
                        }
                    }
                ];
                return await Request.aggregate(aggregationPipeline);
            case 'peopleNotified':
                sortOptions.nbPeopleNotified = sortOrder === 'asc' ? 1 : -1;
                break;
            default:
                sortOptions.timestamp = -1; // Default to newest first
        }
        
        return await requestQuery.sort(sortOptions);
    },

    async toggleSolvedStatus(id: string) {
        const bookRequest = await Request.findById(id);
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

    async toggleUpvote(requestId: string, userId: string) {
        const bookRequest = await Request.findById(requestId);
        if (!bookRequest) {
            throw newErr(404, 'Request not found');
        }

        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        const username = user.username;
        const upvoterIndex = bookRequest.upvoters.indexOf(username);
        
        let isUpvoted: boolean;
        let message: string;

        if (upvoterIndex > -1) {
            // User has already upvoted, remove the upvote
            bookRequest.upvoters.splice(upvoterIndex, 1);
            isUpvoted = false;
            message = 'Upvote removed successfully';
        } else {
            // User hasn't upvoted, add the upvote
            bookRequest.upvoters.push(username);
            isUpvoted = true;
            message = 'Request upvoted successfully';
        }

        await bookRequest.save();

        return {
            message,
            isUpvoted,
            upvoteCount: bookRequest.upvoters.length,
            request: bookRequest
        };
    },
};

export default RequestService;
