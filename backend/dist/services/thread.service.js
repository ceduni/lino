"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const models_1 = require("../models");
const _1 = require(".");
const utilities_1 = require("../utilities/utilities");
const ThreadService = {
    createThread(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const username = yield _1.UserService.getUserName(request.user.id);
            if (!username) {
                throw (0, utilities_1.newErr)(401, 'Unauthorized');
            }
            const { bookId, title } = request.body;
            const book = yield _1.BookService.getBook(bookId);
            if (!book) {
                throw (0, utilities_1.newErr)(404, 'Book not found');
            }
            if (!title) {
                throw (0, utilities_1.newErr)(400, 'Title is required');
            }
            const bookTitle = book.title;
            const thread = new models_1.Thread({
                bookTitle: bookTitle,
                username: username,
                title: title,
                image: book.coverImage,
                messages: []
            });
            yield thread.save();
            return thread;
        });
    },
    deleteThread(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const threadId = request.params.threadId;
            const thread = yield models_1.Thread.findById(threadId);
            if (!thread) {
                throw (0, utilities_1.newErr)(404, 'Thread not found');
            }
            yield thread.deleteOne();
        });
    },
    addThreadMessage(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const username = yield _1.UserService.getUserName(request.user.id);
            if (!username) {
                throw (0, utilities_1.newErr)(401, 'Unauthorized');
            }
            const { content, respondsTo } = request.body;
            const threadId = request.body.threadId;
            const thread = yield models_1.Thread.findById(threadId);
            if (!thread) {
                throw (0, utilities_1.newErr)(404, 'Thread not found');
            }
            const message = {
                username: username,
                content: content,
                respondsTo: respondsTo,
                reactions: []
            };
            thread.messages.push(message);
            yield thread.save();
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
        });
    },
    toggleMessageReaction(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const username = yield _1.UserService.getUserName(request.user.id);
            if (!username) {
                throw (0, utilities_1.newErr)(401, 'Unauthorized');
            }
            const { reactIcon, messageId, threadId } = request.body;
            // Find the thread that contains the message
            const thread = yield models_1.Thread.findById(threadId);
            if (!thread) {
                throw (0, utilities_1.newErr)(404, 'Thread not found');
            }
            // Find the message
            const message = thread.messages.id(messageId);
            if (!message) {
                throw (0, utilities_1.newErr)(404, 'Message not found');
            }
            // Check if the user has already reacted to this message with the same icon
            if (message.reactions.find(r => r.username === username && r.reactIcon === reactIcon)) {
                // Remove the reaction
                message.reactions = message.reactions.filter(r => r.username !== username || r.reactIcon !== reactIcon);
            }
            else {
                // Add the reaction
                message.reactions.push({ username: username, reactIcon: reactIcon, timestamp: new Date() });
            }
            yield thread.save();
            if (message.reactions.length > 0) {
                return message.reactions[message.reactions.length - 1];
            }
            else {
                return null;
            }
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield models_1.Thread.deleteMany({});
        });
    }
};
exports.default = ThreadService;
