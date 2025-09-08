import { issueSchema, bookboxSchema, bookSchema, threadSchema, bookRequestSchema } from "./models.schemas";

export const paginationSchema = {
    type: 'object',
    properties: {
        currentPage: { type: 'number', default: 1 },
        totalPages: { type: 'number', default: 1 },
        totalResults: { type: 'number', default: 0 },
        hasNextPage: { type: 'boolean', default: false },
        hasPrevPage: { type: 'boolean', default: false },
        limit: { type: 'number', default: 20 }
    }
};

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
                    items: {
                        type: 'object',
                        properties: {
                            _id: {type: 'string'},
                            isbn: {type: 'string'},
                            title: {type: 'string'},
                            authors: {type: 'array', items: {type: 'string'}},
                            description: {type: 'string'},
                            coverImage: {type: 'string'},
                            publisher: {type: 'string'},
                            categories: {type: 'array', items: {type: 'string'}},
                            parutionYear: {type: 'number'},
                            pages: {type: 'number'},
                            dateAdded: {type: 'string', format: 'date-time'},
                            bookboxId: {type: 'string'},
                            bookboxName: {type: 'string'}
                        }
                    }
                }, 
                pagination: {
                    ...paginationSchema
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
                }, 
                pagination: {
                    ...paginationSchema
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
                }, 
                pagination: {
                    ...paginationSchema
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
                    items: {
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
                    }
                },
                pagination: {
                    ...paginationSchema
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
                    items: {
                        type: 'object',
                        properties: {
                            _id: {type: 'string'},
                            name: {type: 'string'},
                            owner: {type: 'string'},
                            image: {type: 'string'},
                            longitude: {type: 'number'},
                            latitude: {type: 'number'},
                            boroughId: {type: 'string'},
                            booksCount: {type: 'number'},
                            infoText: {type: 'string'},
                            isActive: {type: 'boolean'},
                            books: {
                                type: 'array', 
                                items: {
                                    type: 'object',
                                    properties: {
                                        _id: {type: 'string'},
                                        isbn: {type: 'string'},
                                        title: {type: 'string'},
                                        authors: {type: 'array', items: {type: 'string'}},
                                        description: {type: 'string'},
                                        coverImage: {type: 'string'},
                                        publisher: {type: 'string'},
                                        categories: {type: 'array', items: {type: 'string'}},
                                        parutionYear: {type: 'number'},
                                        pages: {type: 'number'},
                                        dateAdded: {type: 'string', format: 'date-time'},
                                        bookboxId: {type: 'string'},
                                        bookboxName: {type: 'string'}
                                    }
                                }
                            }
                        }
                    }
                },
                pagination: {
                    ...paginationSchema
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
            isbn: { type: 'string' },
            bookboxId: { type: 'string' },
            bookTitle: { type: 'string' },
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
                            isbn: { type: 'string' },
                            bookTitle: { type: 'string' },
                            bookboxId: { type: 'string' },
                            timestamp: { type: 'string' }
                        }
                    }
                },
                pagination: {
                    ...paginationSchema
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
                    items: {
                        type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            username: { type: 'string' },
                            email: { type: 'string', format: 'email' },
                            bookboxId: { type: 'string' },
                            subject: { type: 'string', minLength: 1 },
                            description: { type: 'string', minLength: 1 },
                            status: { type: 'string', enum: ['open', 'in_progress', 'resolved'], default: 'open' },
                            reportedAt: { type: 'string', format: 'date-time' },
                            resolvedAt: { type: 'string', format: 'date-time', nullable: true }
                        }
                    }
                },
                pagination: {
                    ...paginationSchema
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
                            isAdmin: { type: 'boolean' },
                        }   
                    }
                },
                pagination: {
                    ...paginationSchema
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

export const searchBookRequestsSchema = {
    description: 'Search book requests with filtering, sorting, and pagination. Authentication is optional but required for certain filters.',
    tags: ['books', 'requests'],
    querystring: {
        type: 'object',
        properties: {
            q: { type: 'string' },
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
            },
            limit: { type: 'number', default: 20 },
            page: { type: 'number', default: 1 }
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
            type: 'object',
            properties: {
                requests: {
                    type: 'array',
                    items: {
                        ...bookRequestSchema
                    }
                },
                pagination: {
                    ...paginationSchema
                }
            }
        },
        401: {
            description: 'Authentication required for this filter (notified, upvoted, mine)',
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
