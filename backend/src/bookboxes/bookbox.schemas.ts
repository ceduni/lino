import { bookboxSchema, bookSchema } from '../models.schemas';

export const addBookToBookboxSchema = {
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

export const getBookFromBookBoxSchema = {
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
                book: bookSchema,
                books: { type: 'array', items: { type: 'string' } }
            }
        },
        404: {
            description: 'Error message',
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

export const getBookboxSchema = {
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
            ...bookboxSchema
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
                            longitude: { type: 'number' },
                            latitude: { type: 'number' },
                            booksCount: { type: 'number' },
                            image: { type: 'string' },
                            owner: { type: 'string' },
                            boroughId: { type: 'string' },
                            isActive: { type: 'boolean' }
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


export const followBookBoxSchema = {
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

export const unfollowBookBoxSchema = {
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

export const findNearestBookboxesSchema = {
    description: 'Find nearest bookboxes',
    tags: ['bookboxes'],
    querystring: {
        type: 'object',
        properties: {
            longitude: { type: 'number' },
            latitude: { type: 'number' },
            maxDistance: { type: 'number', default: 5000 }
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
                            id: { type: 'string' },
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