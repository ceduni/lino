import Thread from "../models/thread.model";
import UserService, {notifyUser} from "./user.service";
import User from "../models/user.model";
import BookService from "./book.service";
import {newErr} from "./utilities";

const ThreadService = {
    async createThread(request: any) {
        const username = await UserService.getUserName(request.user.id);
        if (!username) {
            throw newErr(401, 'Unauthorized');
        }
        const { bookId, title } = request.body;
        const book = await BookService.getBook(bookId);
        if (!book) {
            throw newErr(404, 'Book not found');
        }
        if (!title) {
            throw newErr(400, 'Title is required');
        }
        const bookTitle = book.title;
        const thread = new Thread({
            bookTitle: bookTitle,
            username: username,
            title: title,
            image: book.coverImage,
            messages: []
        });
        await thread.save();
        return thread;
    },

    async deleteThread(request: any) {
        const threadId = request.params.threadId;
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw newErr(404, 'Thread not found');
        }
        await thread.deleteOne();
    },

    async addThreadMessage(request: any) {
        // @ts-ignore
        const username = await UserService.getUserName(request.user.id);
        if (!username) {
            throw newErr(401, 'Unauthorized');
        }
        const { content, respondsTo } = request.body;
        const threadId = request.body.threadId;
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw newErr(404, 'Thread not found');
        }
        const message = {
            username: username,
            content: content,
            respondsTo: respondsTo,
            reactions: []
        };
        thread.messages.push(message);
        await thread.save();

        // Notify the user that someone has responded to their message
        if (respondsTo != null) {
            // @ts-ignore
            const parentMessage = thread.messages.id(respondsTo);
            if (!parentMessage) {
                throw newErr(404, 'Parent message not found');
            }
            if (parentMessage.username !== username) {
                const userParent = await User.findOne({ username: parentMessage.username });
                if (!userParent) {
                    throw newErr(404, 'User not found');
                }
                // @ts-ignore
                await notifyUser(userParent.id, `${username} in ${thread.title}`, message.content);
            }
        }

        // Get the _id of the newly created message
        const messageId = thread.messages[thread.messages.length - 1].id;

        return { messageId };
    },

    async toggleMessageReaction(request: any) {
        const username = await UserService.getUserName(request.user.id);
        if (!username) {
            throw newErr(401, 'Unauthorized');
        }
        const { reactIcon, messageId, threadId } = request.body;
        // Find the thread that contains the message
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw newErr(404, 'Thread not found');
        }
        // Find the message
        const message = thread.messages.id(messageId);
        if (!message) {
            throw newErr(404, 'Message not found');
        }

        // Check if the user has already reacted to this message with the same icon
        if (message.reactions.find(r => r.username === username && r.reactIcon === reactIcon)) {
            // Remove the reaction
            // @ts-ignore
            message.reactions = message.reactions.filter(r => r.username !== username || r.reactIcon !== reactIcon);
        } else {
            // Add the reaction
            message.reactions.push({ username: username, reactIcon: reactIcon });
        }

        await thread.save();
        if (message.reactions.length > 0) {
            return message.reactions[message.reactions.length - 1];
        } else {
            return null;
        }
    },


    async searchThreads(request: any) {
        const query = request.query.q;
        let threads = await Thread.find();

        if (query) {
            // Filter using regex for more flexibility
            const regex = new RegExp(query, 'i');
            threads = threads.filter(thread =>
                regex.test(thread.bookTitle) || regex.test(thread.title) || regex.test(thread.username)
            );
        }

        // classify : ['by recent activity', 'by number of messages', 'by creation date']
        let classify = request.query.cls || 'by recent activity';
        const asc = request.query.asc; // Boolean

        if (classify === 'by recent activity') {
            threads.sort((a, b) => {
                const aDate = a.messages.length > 0 ? a.messages[a.messages.length - 1].timestamp.getTime() : 0;
                const bDate = b.messages.length > 0 ? b.messages[b.messages.length - 1].timestamp.getTime() : 0;
                return asc ? aDate - bDate : bDate - aDate;
            });
        } else if (classify === 'by number of messages') {
            threads.sort((a, b) => {
                return asc ? a.messages.length - b.messages.length : b.messages.length - a.messages.length;
            });
        } else if (classify === 'by creation date') {
            threads.sort((a, b) => { // if asc, most recent first
                const aDate = a.timestamp.getTime();
                const bDate = b.timestamp.getTime();
                return asc ? aDate - bDate : bDate - aDate;
            });
        }

        return { threads: threads };
    },

    async clearCollection() {
        await Thread.deleteMany({});
    }
}


export default ThreadService;