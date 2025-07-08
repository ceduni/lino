import { threadSchema } from './models.schemas';

export const createThreadSchema = {
    description: 'Create a new thread',
    tags: ['threads'],
    body: {
        type: 'object',
        required: ['bookId', 'title'],
        properties: {
            bookId: { type: 'string' },
            title: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: {type: 'string'}
        }
    },
    response: {
        201: {
            description: 'Thread created successfully',
            type: 'object',
            properties: {
                threadId: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Bad request',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        },
        404: {
            description: 'Book not found',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }
};

export const deleteThreadSchema = {
    description: 'Delete a thread',
    tags: ['threads'],
    params: {
        type: 'object',
        required: ['threadId'],
        properties: {
            threadId: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: {type: 'string'}
        }
    },
    response: {
        204: {
            description: 'Thread deleted',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Thread not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};

export const addMessageSchema = {
    description: 'Add a new message to a thread',
    tags: ['threads', 'messages'],
    body: {
        type: 'object',
        required: ['threadId', 'content'],
        properties: {
            threadId: { type: 'string' },
            content: { type: 'string' },
            respondsTo: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: {type: 'string'}
        }
    },
    response: {
        201: {
            description: 'Message added successfully',
            type: 'object',
            properties: {
                messageId: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Bad request',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Thread, parent message or user not found',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        },
    }
};

export const toggleReactionSchema = {
    description: 'Toggle a reaction to a message',
    tags: ['threads', 'messages'],
    body: {
        type: 'object',
        required: ['reactIcon', 'threadId', 'messageId'],
        properties: {
            reactIcon: { type: 'string' },
            threadId: { type: 'string' },
            messageId: { type: 'string' }
        }
    },
    headers: {
        type: 'object',
        required: ['Authorization'],
        properties: {
            Authorization: {type: 'string'}
        }
    },
    response: {
        200: {
            description: 'Reaction added successfully',
            type: 'object',
            properties: {
                reaction: {
                    type: 'object',
                    properties: {
                        _id: { type: 'string' },
                        username: { type: 'string' },
                        reactIcon: { type: 'string' },
                        timestamp: { type: 'string' }
                    }
                }
            }
        },
        401: {
            description: 'Unauthorized',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Bad request',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Thread or message not found',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        },
        500: {
            description: 'Internal server error',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }
};

export const searchThreadsSchema = {
    description: 'Search threads',
    tags: ['threads'],
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
            cls: { type: 'string' },
            asc: { type: 'boolean' }
        }
    },
    response: {
        200: {
            description: 'Threads found',
            type: 'object',
            properties: {
                threads: {
                    type: 'array',
                    items: threadSchema
                }
            }
        }
    }
};

export const getThreadSchema = {
    description: 'Get a thread by id',
    tags: ['threads'],
    params: {
        type: 'object',
        required: ['threadId'],
        properties: {
            threadId: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Thread found',
            ...threadSchema
        },
        404: {
            description: 'Thread not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
