export const sendBookRequestSchema = {
    description: 'Send a book request to users',
    tags: ['books', 'users'],
    body: {
        type: 'object',
        properties: {
            title: { type: 'string' },
            customMessage: { type: 'string' }
        },
        required: ['title']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        },
        required: ['authorization']
    },
    response: {
        201: {
            description: 'Book request sent',
            type: 'object',
            properties: {
                _id: { type: 'string' },
                username: { type: 'string' },
                bookTitle: { type: 'string' },
                timestamp: { type: 'string' },
                customMessage: { type: 'string' },
                isSolved: { type: 'boolean' }
            }
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
        },
        required: ['authorization']
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
    description: 'Get book requests',
    tags: ['books', 'users'],
    querystring: {
        type: 'object',
        properties: {
            username: {type: 'string'}
        }
    },
    response: {
        200: {
            description: 'Book requests found',
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    _id: {type: 'string'},
                    username: {type: 'string'},
                    bookTitle: {type: 'string'},
                    timestamp: {type: 'string'},
                    customMessage: {type: 'string'},
                    isSolved: {type: 'boolean'}
                }
            },
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
