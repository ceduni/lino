import Thread from "../models/thread.model";

const ThreadService = {
    async createThread(book_title : string, userId : string, title : string) {
        const thread = new Thread({
            book_title: book_title,
            user_id: userId,
            title: title,
            messages: []
        });
        await thread.save();
        return thread;
    },

    async addThreadMessage(threadId : string, userId : string, content : string, respondsTo : string) {
        const thread = await Thread.findById(threadId);
        if (!thread) {
            throw new Error('Thread not found');
        }
        const message = {
            user_id: userId,
            content: content,
            responds_to: respondsTo,
            reactions: []
        };
        thread.messages.push(message);
        await thread.save();

        // Get the _id of the newly created message
        const messageId = thread.messages[thread.messages.length - 1]._id;

        return { ...message, _id: messageId };
    },

    async toggleMessageReaction(threadId : string, messageId : string, userId : string, reactIcon : string) {
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
        if (message.reactions.find(r => r.user_id === userId && r.react_icon === reactIcon)) {
            // Remove the reaction
            // @ts-ignore
            message.reactions = message.reactions.filter(r => r.user_id !== userId || r.react_icon !== reactIcon);
        } else {
            // Add the reaction
            message.reactions.push({ user_id: userId, react_icon: reactIcon });
        }

        await thread.save();
        return message.reactions[message.reactions.length - 1];
    }

}


export default ThreadService;