import Thread from "../models/thread.model";

const ThreadService = {
    async createThread(book_title : string, username : string, title : string) {
        const thread = new Thread({
            book_title: book_title,
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
            responds_to: respondsTo,
            reactions: []
        };
        thread.messages.push(message);
        await thread.save();

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
        if (message.reactions.find(r => r.username === username && r.react_icon === reactIcon)) {
            // Remove the reaction
            // @ts-ignore
            message.reactions = message.reactions.filter(r => r.username !== username || r.react_icon !== reactIcon);
        } else {
            // Add the reaction
            message.reactions.push({ username: username, react_icon: reactIcon });
        }

        await thread.save();
        return message.reactions[message.reactions.length - 1];
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
    }

}


export default ThreadService;