import Thread from "../models/thread.model";

const ThreadService = {
    async createThread(bookId : String, userId : String, title : String) {
        const thread = new Thread({
            book_id: bookId,
            user_id: userId,
            title: title,
            messages: []
        });
        await thread.save();
        return thread;
    },

    async addThreadMessage(threadId : String, userId : String, content : String, respondsTo : String) {
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
        return message;
    },

    async toggleMessageReaction(threadId : String, messageId : String, userId : String, reactIcon : String) {
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
        return message;
    }

}


export default ThreadService;