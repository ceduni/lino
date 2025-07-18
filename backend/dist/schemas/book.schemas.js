"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTransactionHistorySchema = exports.getBookRequestsSchema = exports.getBookSchema = exports.deleteBookRequestSchema = exports.sendBookRequestSchema = exports.searchBooksSchema = exports.getBookInfoFromISBNSchema = void 0;
const models_schemas_1 = require("./models.schemas");
exports.getBookInfoFromISBNSchema = {
    description: 'Get book info from ISBN',
    tags: ['books'],
    params: {
        type: 'object',
        properties: {
            isbn: { type: 'string' }
        },
        required: ['isbn']
    },
    response: {
        200: {
            description: 'Book found',
            type: 'object',
            properties: {
                title: { type: 'string' },
                authors: { type: 'array', items: { type: 'string' } },
                isbn: { type: 'string' },
                description: { type: 'string' },
                coverImage: { type: 'string' },
                publisher: { type: 'string' },
                categories: { type: 'array', items: { type: 'string' } },
                parutionYear: { type: ['number', 'null'] },
                pages: { type: ['number', 'null'] }
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
exports.searchBooksSchema = {
    description: 'Search books across all bookboxes',
    tags: ['books'],
    querystring: {
        type: 'object',
        properties: {
            kw: { type: 'string' },
            cls: { type: 'string' },
            asc: { type: 'boolean' }
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
                            dateLastAction: { type: 'string' },
                            bookboxId: { type: 'string' },
                            bookboxName: { type: 'string' }
                        }
                    }
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
exports.sendBookRequestSchema = {
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
    querystring: {
        type: 'object',
        properties: {
            latitude: { type: 'number' },
            longitude: { type: 'number' }
        },
        required: ['latitude', 'longitude']
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
exports.getBookSchema = {
    description: 'Get book',
    tags: ['books'],
    params: {
        type: 'object',
        properties: {
            id: { type: 'string' }
        },
        required: ['id']
    },
    response: {
        200: Object.assign({ description: 'Book found' }, models_schemas_1.bookSchema),
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
exports.getBookRequestsSchema = {
    description: 'Get book requests',
    tags: ['books', 'users'],
    querystring: {
        type: 'object',
        properties: {
            username: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Book requests found',
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    _id: { type: 'string' },
                    username: { type: 'string' },
                    bookTitle: { type: 'string' },
                    timestamp: { type: 'string' },
                    customMessage: { type: 'string' },
                }
            },
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
exports.getTransactionHistorySchema = {
    description: 'Get transaction history',
    tags: ['books', 'transactions'],
    querystring: {
        type: 'object',
        properties: {
            username: { type: 'string' },
            bookTitle: { type: 'string' },
            bookboxId: { type: 'string' },
            limit: { type: 'number' }
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
