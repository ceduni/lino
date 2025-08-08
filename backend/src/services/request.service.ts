import { User, Request } from "../models";
import { NotificationService } from ".";
import { newErr } from "../utilities/utilities";

const RequestService = {
    async requestBookToUsers(
        id: string,
        title: string,
        customMessage?: string
    ) {
        const user = await User.findById(id);
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
                await NotificationService.createNotification(
                    usersToNotify[i]._id.toString(),
                    ['book_request'],
                    title
                );
            }
        }

        const newRequest = new Request({
            username: user.username,
            bookTitle: title,
            customMessage
        });
        await newRequest.save();
        return newRequest;
    },

    async deleteBookRequest(id: string) {
        const requestToDelete = await Request.findById(id);
        if (!requestToDelete) {
            throw newErr(404, 'Request not found');
        }
        await requestToDelete.deleteOne();
    },

    async getBookRequests(username?: string) {
        if (!username) {
            return Request.find();
        } else {
            return Request.find({username: username});
        }
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
};

export default RequestService;
