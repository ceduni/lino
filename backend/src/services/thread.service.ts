import { Thread } from "../models";
import { UserService, BookService } from ".";
import { newErr } from "../utilities/utilities";
import { 
    AuthenticatedRequest,
    ThreadCreateData, 
    MessageCreateData, 
    ReactionData
} from '../types';

const ThreadService = {
    async createThread(request: AuthenticatedRequest & { body: ThreadCreateData }) {
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

    async deleteThread(request: { params: { threadId: string } }) {
        const threadId = request.params.threadId;
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw newErr(404, 'Thread not found');
        }
        await thread.deleteOne();
    },

    async addThreadMessage(request: AuthenticatedRequest & { body: MessageCreateData }) {
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
        // if (respondsTo != null) {
        //     const parentMessage = thread.messages.id(respondsTo);
        //     if (!parentMessage) {
        //         throw newErr(404, 'Parent message not found');
        //     }
        //     if (parentMessage.username !== username) {
        //         const userParent = await User.findOne({ username: parentMessage.username });
        //         if (!userParent) {
        //             throw newErr(404, 'User not found');
        //         }
        //         await notifyUser(userParent.id, `${username} in ${thread.title}`, message.content);
        //     }
        // }

        // Get the _id of the newly created message
        const messageId = thread.messages[thread.messages.length - 1].id;

        return { messageId };
    },

    async toggleMessageReaction(request: AuthenticatedRequest & { body: ReactionData }) {
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
            message.reactions = message.reactions.filter(r => r.username !== username || r.reactIcon !== reactIcon) as any;
        } else {
            // Add the reaction
            message.reactions.push({ username: username, reactIcon: reactIcon, timestamp: new Date() });
        }

        await thread.save();
        if (message.reactions.length > 0) {
            return message.reactions[message.reactions.length - 1];
        } else {
            return null;
        }
    },

    async clearCollection() {
        await Thread.deleteMany({});
    }
}


export default ThreadService;
