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
exports.reinitDatabase = exports.newErr = exports.clearCollectionSchema = exports.userSchema = exports.threadSchema = exports.bookSchema = void 0;
exports.bookSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        qrCodeId: { type: 'string' },
        title: { type: 'string' },
        authors: { type: 'array', items: { type: 'string' } },
        isbn: { type: 'string' },
        description: { type: 'string' },
        coverImage: { type: 'string' },
        publisher: { type: 'string' },
        categories: { type: 'array', items: { type: 'string' } },
        parutionYear: { type: 'number' },
        pages: { type: 'number' },
        takenHistory: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    username: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' }
                }
            }
        },
        givenHistory: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    username: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' }
                }
            }
        },
        dateLastAction: { type: 'string', format: 'date-time' }
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
exports.userSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        password: { type: 'string' },
        email: { type: 'string' },
        phone: { type: 'string' },
        favoriteBooks: { type: 'array', items: { type: 'string' } },
        trackedBooks: { type: 'array', items: { type: 'string' } },
        notificationKeyWords: { type: 'array', items: { type: 'string' } },
        ecologicalImpact: {
            type: 'object',
            properties: {
                carbonSavings: { type: 'number' },
                savedWater: { type: 'number' },
                savedTrees: { type: 'number' }
            }
        },
        notifications: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    timestamp: { type: 'string', format: 'date-time' },
                    title: { type: 'string' },
                    content: { type: 'string' },
                    read: { type: 'boolean' }
                }
            }
        },
        getAlerted: { type: 'boolean' },
        bookHistory: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    bookId: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' },
                    given: { type: 'boolean' }
                }
            }
        }
    }
};
exports.clearCollectionSchema = {
    description: 'Clear collection',
    tags: ['users', 'books', 'thread'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' } // JWT token
        }
    },
    response: {
        200: {
            description: 'Collection cleared',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        500: {
            description: 'Internal server error',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
class CustomError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.statusCode = statusCode;
        Error.captureStackTrace(this, this.constructor);
    }
}
function newErr(statusCode, message) {
    return new CustomError(message, statusCode);
}
exports.newErr = newErr;
function createAdminUser(server) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield server.inject({
                method: 'POST',
                url: '/users/register',
                payload: {
                    username: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                    email: process.env.ADMIN_EMAIL,
                },
            });
            const response = yield server.inject({
                method: 'POST',
                url: '/users/login',
                payload: {
                    identifier: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                },
            });
            return response.json().token;
        }
        catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Unknown error';
            if (errorMessage.includes('already taken')) {
                console.log('Admin user already exists.');
            }
            else {
                throw err;
            }
            return '';
        }
    });
}
function reinitDatabase(server) {
    return __awaiter(this, void 0, void 0, function* () {
        const token = yield createAdminUser(server);
        yield server.inject({
            method: 'DELETE',
            url: '/users/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/books/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/threads/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        console.log('Database reinitialized.');
        return token;
    });
}
exports.reinitDatabase = reinitDatabase;
