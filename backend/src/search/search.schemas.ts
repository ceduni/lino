import { issueSchema } from "../issues/issue.schemas";
import { bookboxSchema, bookSchema, threadSchema } from "../models.schemas";

export const searchBooksSchema = {
    description: 'Search books across all bookboxes',
    tags: ['books'],
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
            cls: { type: 'string' },
            asc: { type: 'boolean' },
            limit: { type: 'number', default: 20 },
            page: { type: 'number', default: 1 }
        }
    },
    response: {
        200: {
            description: 'Books found',
            type: 'object',
            properties: {
                books: {
                    type: 'array',
                    items: bookSchema
                }
            }
        },
        404: {
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

export const searchBookboxesSchema = {
    description: 'Search bookboxes',
    tags: ['bookboxes'],
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
            cls: { type: 'string' },
            asc: { type: 'boolean' },
            longitude: { type: 'number' },
            latitude: { type: 'number' },
            limit: { type: 'number', default: 20 },
            page: { type: 'number', default: 1 }
        }
    },
    response: {
        200: {
            description: 'Bookboxes found', 
            type: 'object',
            properties: {
                bookboxes: {
                    type: 'array',
                    items: {
                        type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            name: { type: 'string' },
                            infoText: { type: 'string' },
                            longitude: { type: 'number' },
                            latitude: { type: 'number' },
                            booksCount: { type: 'number' },
                            image: { type: 'string' },
                            owner: { type: 'string' },
                            boroughId: { type: 'string' },
                            isActive: { type: 'boolean' },
                            distance: { type: 'number' } // distance from search point
                        }
                    }
                }
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
                error: {type: 'string'}
            }
        }
    }
};

export const findNearestBookboxesSchema = {
    description: 'Find nearest bookboxes',
    tags: ['bookboxes'],
    querystring: {
        type: 'object',
        properties: {
            longitude: { type: 'number' },
            latitude: { type: 'number' },
            maxDistance: { type: 'number' },
            searchByBorough: { type: 'boolean' },
            limit: { type: 'number', default: 20 },
            page: { type: 'number', default: 1 }
        },
        required: ['longitude', 'latitude']
    },
    response: {
        200: {
            description: 'Nearest bookboxes found',
            type: 'array',
            items: {
                type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            name: { type: 'string' },
                            infoText: { type: 'string' },
                            longitude: { type: 'number' },
                            latitude: { type: 'number' },
                            booksCount: { type: 'number' },
                            image: { type: 'string' },
                            owner: { type: 'string' },
                            boroughId: { type: 'string' },
                            isActive: { type: 'boolean' }
                        }
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


export const searchMyManagedBookboxesSchema = {
    description: 'Search for bookboxes owned by the admin',
    tags: ['admin', 'bookboxes'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' }
        }
    },
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
            cls: { type: 'string' }, // classification type
            asc: { type: 'boolean' }, // ascending order
            limit: { type: 'number', default: 20 },
            page: { type: 'number', default: 1 }
        },
    },
    response: {
        200: {
            description: 'List of bookboxes',
            type: 'object',
            properties: {
                bookboxes: {
                    type: 'array',
                    items: bookboxSchema
                }
            }
        },
        400: {
            description: 'Invalid query parameters',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
    }
};

export const searchTransactionHistorySchema = {
    description: 'Get transaction history',
    tags: ['books', 'transactions'],
    querystring: {
        type: 'object',
        properties: {
            username: { type: 'string' },
            bookTitle: { type: 'string' },
            bookboxId: { type: 'string' },
            limit: { type: 'number' },
            page: { type: 'number' }
        }
    },
    response: {
        200: {
            description: 'Transaction history found',
            type: 'object',
            properties: {
                transactions: {
                    type: 'array',
                    items: {
                        type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            username: { type: 'string' },
                            action: { type: 'string' },
                            bookTitle: { type: 'string' },
                            bookboxId: { type: 'string' },
                            timestamp: { type: 'string' }
                        }
                    }
                }
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

export const searchIssuesSchema = {
    description: 'Search issues',
    tags: ['issues'],
    querystring: {
        type: 'object',
        properties: {
            username: { type: 'string' },
            bookboxId: { type: 'string' },
            status: { type: 'string', enum: ['open', 'on_progress', 'resolved'] },
            oldestFirst: { type: 'boolean' },
            limit: { type: 'number' },
            page: { type: 'number' }
        }
    },
    response: {
        200: {
            description: 'Issues found',
            type: 'object',
            properties: {
                issues: {
                    type: 'array',
                    items: issueSchema
                }
            }
        },
        400: {
            description: 'Invalid query parameters',
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


export const searchUsersSchema = {
    description: 'Search users',
    tags: ['users'],
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
            limit: { type: 'number', default: 20 },
            page: { type: 'number', default: 1 }
        }
    },
    response: {
        200: {
            description: 'Users found',
            type: 'object',
            properties: {
                users: {
                    type: 'array',
                    items: {
                        type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            username: { type: 'string' },
                            email: { type: 'string' },
                        }   
                    }
                }
            }
        },
        400: {
            description: 'Invalid query parameters',
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