"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBookSchema = exports.getBookInfoFromISBNSchema = void 0;
const _1 = require(".");
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
        200: Object.assign({ description: 'Book found' }, _1.bookSchema),
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
