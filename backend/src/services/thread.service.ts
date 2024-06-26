import Thread from "../models/thread.model";
import {notifyUser} from "./user.service";
import User from "../models/user.model";
import BookService from "./book.service";

const ThreadService = {
    async createThread(bookId : string, username : string, title : string) {
        const book = await BookService.getBook(bookId);
        if (!book) {
            throw new Error('Book not found');
        }
        const bookTitle = book.title;
        const thread = new Thread({
            bookTitle: bookTitle,
            username: username,
            title: title,
            messages: []
        });
        await thread.save();
        return thread;
    },

    async addThreadMessage(threadId : string, username : string, content : string, respondsTo : string) {
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw new Error('Thread not found');
        }
        const message = {
            username: username,
            content: content,
            respondsTo: respondsTo,
            reactions: []
        };
        thread.messages.push(message);
        await thread.save();

        // Notify the user that their message has been added
        if (respondsTo) {
            // Notify the user that their message has been added
            // @ts-ignore
            const parentMessage = thread.messages.id(respondsTo);
            if (!parentMessage) {
                throw new Error('Parent message not found');
            }
            if (parentMessage.username !== username) {
                const userParent = await User.findOne({ username: parentMessage.username });
                if (!userParent) {
                    throw new Error('User not found');
                }
                // @ts-ignore
                await notifyUser(userParent.id, `${username} responded to your message in the thread "${thread.title}"`);
            }
        }

        // Get the _id of the newly created message
        const messageId = thread.messages[thread.messages.length - 1]._id;

        return { ...message, _id: messageId };
    },

    async toggleMessageReaction(threadId : string, messageId : string, username : string, reactIcon : string) {
        // Find the thread that contains the message
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw new Error('Thread not found');
        }
        // Find the message
        const message = thread.messages.id(messageId);
        if (!message) {
            throw new Error('Message not found');
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
        let threads = await Thread.find({
            $or: [
                {title: {$regex: query, $options: 'i'}},
                {username: {$regex: query, $options: 'i'}}
            ]
        });

        // classify : ['by recent activity', 'by number of messages']
        let classify = request.query.cls;
        if (!classify) {
            classify = 'by recent activity';
        }
        let asc = request.query.asc === 'true';
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
        }

        return threads;
    },

    async clearCollection() {
        await Thread.deleteMany({});
    }
}


export default ThreadService;