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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const thread_model_1 = __importDefault(require("../models/thread.model"));
const user_service_1 = require("./user.service");
const user_model_1 = __importDefault(require("../models/user.model"));
const book_service_1 = __importDefault(require("./book.service"));
const ThreadService = {
    createThread(bookId, username, title) {
        return __awaiter(this, void 0, void 0, function* () {
            const book = yield book_service_1.default.getBook(bookId);
            if (!book) {
                throw new Error('Book not found');
            }
            const bookTitle = book.title;
            const thread = new thread_model_1.default({
                bookTitle: bookTitle,
                username: username,
                title: title,
                messages: []
            });
            yield thread.save();
            return thread;
        });
    },
    addThreadMessage(threadId, username, content, respondsTo) {
        return __awaiter(this, void 0, void 0, function* () {
            const thread = yield thread_model_1.default.findById(threadId);
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
            yield thread.save();
            // Notify the user that their message has been added
            if (respondsTo != null) {
                // Notify the user that their message has been added
                // @ts-ignore
                const parentMessage = thread.messages.id(respondsTo);
                if (!parentMessage) {
                    throw new Error('Parent message not found');
                }
                if (parentMessage.username !== username) {
                    const userParent = yield user_model_1.default.findOne({ username: parentMessage.username });
                    if (!userParent) {
                        throw new Error('User not found');
                    }
                    // @ts-ignore
                    yield (0, user_service_1.notifyUser)(userParent.id, `${username} responded to your message in the thread "${thread.title}"`);
                }
            }
            // Get the _id of the newly created message
            const messageId = thread.messages[thread.messages.length - 1].id;
            return Object.assign(Object.assign({}, message), { id: messageId });
        });
    },
    toggleMessageReaction(threadId, messageId, username, reactIcon) {
        return __awaiter(this, void 0, void 0, function* () {
            // Find the thread that contains the message
            const thread = yield thread_model_1.default.findById(threadId);
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
            }
            else {
                // Add the reaction
                message.reactions.push({ username: username, reactIcon: reactIcon });
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
    searchThreads(request) {
        return __awaiter(this, void 0, void 0, function* () {
            let query = request.query.q;
            if (!query) {
                query = '';
            }
            let threads = yield thread_model_1.default.find({
                $or: [
                    { bookTitle: { $regex: query, $options: 'i' } },
                    { title: { $regex: query, $options: 'i' } },
                    { username: { $regex: query, $options: 'i' } }
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
            }
            else if (classify === 'by number of messages') {
                threads.sort((a, b) => {
                    return asc ? a.messages.length - b.messages.length : b.messages.length - a.messages.length;
                });
            }
            return { threads: threads };
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield thread_model_1.default.deleteMany({});
        });
    }
};
exports.default = ThreadService;
