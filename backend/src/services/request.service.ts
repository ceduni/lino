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

        // Find users who share favourite locations (by boroughId) or follow chosen bookboxes
        const usersToNotify = await User.find({
            $and: [
                {
                    $or: [
                        // Users who have favourite locations with matching boroughIds
                        ...(userBoroughIds.length > 0 ? [{
                            'favouriteLocations.boroughId': { $in: userBoroughIds }
                        }] : []),
                        // Users who follow at least one of the specified bookboxes
                        ...(bookboxIds.length > 0 ? [{
                            followedBookboxes: { $in: bookboxIds }
                        }] : [])
                    ]
                },
                // Users who have opted in for book request notifications
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
