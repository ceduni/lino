import { bookRequestSchema } from ".";

export const sendBookRequestSchema = {
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
        201: {
            description: 'Book request sent',
            ...bookRequestSchema
        },
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

export const deleteBookRequestSchema = {
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

export const getBookRequestsSchema = {
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
            items: {
                ...bookRequestSchema
            },
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
                error: {type: 'string'}
            }
        }
    }
};

export const toggleSolvedStatusSchema = {
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

export const toggleUpvoteSchema = {
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
                request: {
                    ...bookRequestSchema
                }
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
