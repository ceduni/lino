"use strict";
// Model schemas that match the actual Mongoose models
Object.defineProperty(exports, "__esModule", { value: true });
exports.bookRequestSchema = exports.transactionSchema = exports.threadSchema = exports.notificationSchema = exports.userSchema = exports.bookboxSchema = exports.bookSchema = void 0;
exports.bookSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        isbn: { type: 'string' },
        title: { type: 'string' },
        authors: { type: 'array', items: { type: 'string' } },
        description: { type: 'string' },
        coverImage: { type: 'string' },
        publisher: { type: 'string' },
        categories: { type: 'array', items: { type: 'string' } },
        parutionYear: { type: 'number' },
        pages: { type: 'number' },
        dateAdded: { type: 'string', format: 'date-time' }
    }
};
exports.bookboxSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        name: { type: 'string' },
        image: { type: 'string' },
        longitude: { type: 'number' },
        latitude: { type: 'number' },
        boroughId: { type: 'string' },
        infoText: { type: 'string' },
        books: { type: 'array', items: exports.bookSchema }
    }
};
exports.userSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        password: { type: 'string' },
        email: { type: 'string' },
        phone: { type: 'string' },
        requestNotificationRadius: { type: 'number', default: 5 },
        favouriteGenres: { type: 'array', items: { type: 'string' } },
        boroughId: { type: 'string' },
        numSavedBooks: { type: 'number' },
        followedBookboxes: { type: 'array', items: { type: 'string' } },
        createdAt: { type: 'string', format: 'date-time' }
    }
};
exports.notificationSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        userId: { type: 'string' },
        bookId: { type: 'string' },
        bookTitle: { type: 'string' },
        bookboxId: { type: 'string' },
        reason: {
            type: 'array',
            items: {
                type: 'string',
                enum: ['fav_bookbox', 'same_borough', 'fav_genre', 'book_request']
            }
        },
        read: { type: 'boolean' },
        createdAt: { type: 'string', format: 'date-time' }
    }
};
exports.threadSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        title: { type: 'string' },
        image: { type: 'string' },
        bookTitle: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
        messages: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    _id: { type: 'string' },
                    username: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' },
                    content: { type: 'string' },
                    respondsTo: { type: 'string' },
                    reactions: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                _id: { type: 'string' },
                                username: { type: 'string' },
                                reactIcon: { type: 'string' },
                                timestamp: { type: 'string', format: 'date-time' }
                            }
                        }
                    }
                }
            }
        }
    }
};
exports.transactionSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        action: { type: 'string', enum: ['added', 'took'] },
        bookTitle: { type: 'string' },
        bookboxId: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' }
    }
};
exports.bookRequestSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        bookTitle: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
        customMessage: { type: 'string' }
    }
};
