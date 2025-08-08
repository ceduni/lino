import { bookSchema } from '.';
import { createResponseSchema } from './utils';

export const getBookInfoFromISBNSchema = {
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
                title: {type: 'string'},
                authors: {type: 'array', items: {type: 'string'}},
                isbn: {type: 'string'},
                description: {type: 'string'},
                coverImage: {type: 'string'},
                publisher: {type: 'string'},
                categories: {type: 'array', items: {type: 'string'}},
                parutionYear: {type: ['number', 'null']},
                pages: {type: ['number', 'null']}
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


export const getBookSchema = {
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
        200: {
            description: 'Book found',
            ...bookSchema
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
                error: {type: 'string'}
            }
        }
    }
};
