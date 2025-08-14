"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toggleUpvoteSchema = exports.toggleSolvedStatusSchema = exports.getBookRequestsSchema = exports.deleteBookRequestSchema = exports.sendBookRequestSchema = void 0;
const _1 = require(".");
exports.sendBookRequestSchema = {
    description: 'Send a book request to users',
    tags: ['books', 'users'],
    body: {
        type: 'object',
        properties: {
            title: { type: 'string' },
            bookboxIds: {
                type: 'array',
                items: { type: 'string' }
            },
            customMessage: { type: 'string' }
        },
        required: ['title']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        }
    },
    response: {
        201: Object.assign({ description: 'Book request sent' }, _1.bookRequestSchema),
        400: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
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
exports.deleteBookRequestSchema = {
    description: 'Delete a book request',
    tags: ['books', 'users'],
    params: {
        type: 'object',
        properties: {
            id: { type: 'string' }
        },
        required: ['id']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        }
    },
    response: {
        204: {
            description: 'Book request deleted',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        404: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
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
exports.getBookRequestsSchema = {
    description: 'Get book requests with filtering and sorting options',
    tags: ['books', 'users'],
    querystring: {
        type: 'object',
        properties: {
            username: { type: 'string' },
            filter: {
                type: 'string',
                enum: ['all', 'notified', 'upvoted', 'mine'],
                default: 'all'
            },
            sortBy: {
                type: 'string',
                enum: ['date', 'upvoters', 'peopleNotified'],
                default: 'date'
            },
            sortOrder: {
                type: 'string',
                enum: ['asc', 'desc'],
                default: 'desc'
            }
        }
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Book requests found',
            type: 'array',
            items: Object.assign({}, _1.bookRequestSchema),
        },
        401: {
            description: 'Authentication required for this filter',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        500: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
exports.toggleSolvedStatusSchema = {
    description: 'Toggle the solved status of a book request',
    tags: ['books', 'users'],
    params: {
        type: 'object',
        properties: {
            id: { type: 'string' }
        },
        required: ['id']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        },
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Book request solved status toggled',
            type: 'object',
            properties: {
                message: { type: 'string' },
                isSolved: { type: 'boolean' }
            }
        },
        404: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
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
exports.toggleUpvoteSchema = {
    description: 'Toggle upvote on a book request',
    tags: ['books', 'users'],
    params: {
        type: 'object',
        properties: {
            id: { type: 'string' }
        },
        required: ['id']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        },
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Book request upvote toggled',
            type: 'object',
            properties: {
                message: { type: 'string' },
                isUpvoted: { type: 'boolean' },
                upvoteCount: { type: 'number' },
                request: Object.assign({}, _1.bookRequestSchema)
            }
        },
        404: {
            description: 'Request or user not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
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
