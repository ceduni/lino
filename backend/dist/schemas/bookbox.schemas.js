"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.unfollowBookBoxSchema = exports.followBookBoxSchema = exports.getBookboxSchema = exports.removeBookFromBookBoxSchema = exports.getBookFromBookBoxSchema = exports.addBookToBookboxSchema = void 0;
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
                book: (0, models_schemas_1.createBookSchema)(),
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
exports.removeBookFromBookBoxSchema = {
    description: 'Remove book from bookbox',
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
            description: 'Book removed successfully',
            type: 'object',
            properties: {
                message: { type: 'string' },
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
        200: Object.assign({ description: 'Bookbox found' }, (0, models_schemas_1.createBookboxSchema)()),
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
exports.followBookBoxSchema = {
    description: 'Follow a bookbox',
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
            authorization: { type: 'string' }
        },
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Bookbox followed',
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
exports.unfollowBookBoxSchema = {
    description: 'Unfollow a bookbox',
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
            authorization: { type: 'string' }
        },
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Bookbox unfollowed',
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
