"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateBookBoxSchema = exports.deleteBookBoxSchema = exports.searchBookboxesSchema = exports.addNewBookboxSchema = exports.getBookboxSchema = exports.getBookFromBookBoxSchema = exports.addBookToBookboxSchema = void 0;
const models_schemas_1 = require("./models.schemas");
exports.addBookToBookboxSchema = {
    description: 'Add a book to a bookbox',
    tags: ['books', 'bookboxes'],
    params: {
        type: 'object',
        properties: {
            bookboxId: { type: 'string' }
        },
        required: ['bookboxId']
    },
    body: {
        type: 'object',
        properties: {
            title: { type: 'string' },
            authors: { type: 'array', items: { type: 'string' } },
            isbn: { type: 'string' },
            description: { type: 'string' },
            coverImage: { type: 'string' },
            publisher: { type: 'string' },
            categories: { type: 'array', items: { type: 'string' } },
            parutionYear: { type: "number" },
            pages: { type: "number" }
        },
        required: ['title'],
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' },
            bm_token: { type: 'string' }
        },
        required: ['bm_token']
    },
    response: {
        201: {
            description: 'Book added to bookbox',
            type: 'object',
            properties: {
                bookId: { type: 'string' },
                books: { type: 'array', items: { type: 'string' } }
            }
        },
        400: {
            description: 'Error in the request',
            type: 'object',
            properties: {
                error: { type: 'string' }
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
exports.getBookFromBookBoxSchema = {
    description: 'Get book from bookbox',
    tags: ['books', 'bookboxes'],
    params: {
        type: 'object',
        properties: {
            bookId: { type: 'string' },
            bookboxId: { type: 'string' }
        },
        required: ['bookId', 'bookboxId']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' },
            bm_token: { type: 'string' }
        },
        required: ['bm_token']
    },
    response: {
        200: {
            description: 'Book found',
            type: 'object',
            properties: {
                book: models_schemas_1.bookSchema,
                books: { type: 'array', items: { type: 'string' } }
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
exports.getBookboxSchema = {
    description: 'Get bookbox',
    tags: ['bookboxes'],
    params: {
        type: 'object',
        properties: {
            bookboxId: { type: 'string' }
        },
        required: ['bookboxId']
    },
    response: {
        200: {
            description: 'Bookbox found',
            type: 'object',
            properties: {
                id: { type: 'string' },
                name: { type: 'string' },
                latitude: { type: 'number' },
                longitude: { type: 'number' },
                boroughId: { type: 'string' },
                infoText: { type: 'string' },
                image: { type: 'string' },
                books: { type: 'array', items: models_schemas_1.bookSchema }
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
exports.addNewBookboxSchema = {
    description: 'Add new bookbox',
    tags: ['bookboxes'],
    body: {
        type: 'object',
        properties: {
            name: { type: 'string' },
            infoText: { type: 'string' },
            latitude: { type: 'number' },
            longitude: { type: 'number' },
            image: { type: 'string' }
        },
        required: ['name', 'infoText', 'latitude', 'longitude', 'image'],
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
            description: 'Bookbox added',
            type: 'object',
            properties: {
                _id: { type: 'string' },
                name: { type: 'string' },
                latitude: { type: 'number' },
                longitude: { type: 'number' },
                image: { type: 'string' },
                boroughId: { type: 'string' },
                infoText: { type: 'string' },
                books: { type: 'array', items: { type: 'string' } }
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
exports.searchBookboxesSchema = {
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
                            id: { type: 'string' },
                            name: { type: 'string' },
                            infoText: { type: 'string' },
                            image: { type: 'string' },
                            books: { type: 'array', items: models_schemas_1.bookSchema },
                            latitude: { type: 'number' },
                            longitude: { type: 'number' },
                            boroughId: { type: 'string' }
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
                error: { type: 'string' }
            }
        }
    }
};
exports.deleteBookBoxSchema = {
    description: 'Delete a bookbox',
    tags: ['bookboxes'],
    params: {
        type: 'object',
        properties: {
            bookboxId: { type: 'string' }
        },
        required: ['bookboxId']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' },
        },
    },
    response: {
        204: {
            description: 'Bookbox deleted'
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
exports.updateBookBoxSchema = {
    description: 'Update a bookbox',
    tags: ['bookboxes'],
    params: {
        type: 'object',
        properties: {
            bookboxId: { type: 'string' }
        },
        required: ['bookboxId']
    },
    body: {
        type: 'object',
        properties: {
            name: { type: 'string' },
            infoText: { type: 'string' },
            latitude: { type: 'number' },
            longitude: { type: 'number' },
            image: { type: 'string' },
        },
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' },
        },
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Bookbox updated',
            type: 'object',
            properties: {
                _id: { type: 'string' },
                name: { type: 'string' },
                latitude: { type: 'number' },
                longitude: { type: 'number' },
                image: { type: 'string' },
                boroughId: { type: 'string' },
                infoText: { type: 'string' },
            }
        },
        400: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        404: {
            description: 'Bookbox not found',
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
