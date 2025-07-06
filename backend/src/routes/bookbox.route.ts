import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookboxService from "../services/bookbox.service";
import {bookSchema, clearCollectionSchema} from "../services/utilities";
import { BookAddData } from "../types/book.types";
import { AuthenticatedRequest } from "../types/common.types";

async function addBookToBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.addBook(request as AuthenticatedRequest & { body: BookAddData; params: { bookboxId: string } });
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

const addBookToBookboxSchema = {
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

async function getBookFromBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.getBookFromBookBox(request as AuthenticatedRequest & { params: { bookId: string; bookboxId: string } });
        reply.send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

const getBookFromBookBoxSchema = {
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

interface GetBookBoxParams extends RouteGenericInterface {
    Params: {
        bookboxId: string
    }
}

async function getBookbox(request: FastifyRequest<GetBookBoxParams>, reply: FastifyReply) {
    try {
        const response = await BookboxService.getBookBox(request.params.bookboxId);
        reply.send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(404).send({error: message});
    }
}

const getBookboxSchema = {
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
                books: { type: 'array', items: bookSchema }
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
                error: {type: 'string'}
            }

        }
    }
};

async function addNewBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.addNewBookbox(request as { 
            body: { 
                name: string; 
                image?: string; 
                longitude: number; 
                latitude: number; 
                boroughId: string;
                infoText?: string; 
            } 
        });
        reply.code(201).send(response);
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(400).send({error: message});
    }
}

const addNewBookboxSchema = {
    description: 'Add new bookbox',
    tags: ['bookboxes'],
    body: {
        type: 'object',
        properties: {
            name: { type: 'string' },
            infoText: { type: 'string' },
            latitude: { type: 'number' },
            longitude: { type: 'number' },
            boroughId: { type: 'string' },
            image: { type: 'string' }
        },
        required: ['name', 'infoText', 'latitude', 'longitude', 'boroughId', 'image'],
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
                error: {type: 'string'}
            }
        }
    }
};

async function searchBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const bookboxes = await BookboxService.searchBookboxes(request as { 
            query: { 
                kw?: string; 
                cls?: string; 
                asc?: boolean; 
                longitude?: number; 
                latitude?: number; 
            } 
        });
        reply.send({bookboxes : bookboxes});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(400).send({error: message});
    }
}

const searchBookboxesSchema = {
    description: 'Search bookboxes',
    tags: ['bookboxes'],
    querystring: {
        type: 'object',
        properties: {
            kw: { type: 'string' },
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
                            books: { type: 'array', items: bookSchema },
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
                error: {type: 'string'}
            }
        }
    }
}

async function deleteBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.deleteBookBox(request as AuthenticatedRequest & { params: { bookboxId: string } });
        reply.code(204).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';  
        reply.code(statusCode).send({error: message});
    }
}

const deleteBookBoxSchema = {
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
                error: {type: 'string'}
            }
        }
    }
};


async function updateBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookboxService.updateBookBox(request as AuthenticatedRequest & { body: { 
            name?: string;
            image?: string;
            longitude?: number; 
            latitude?: number;
            infoText?: string;
            boroughId?: string;
        }; params: { bookboxId: string } });
        reply.code(200).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({error: message});
    }
}

const updateBookBoxSchema = {
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
            boroughId: { type: 'string' }
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


interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    bookManipAuth: (request: FastifyRequest, reply: FastifyReply) => void;
}

export default async function bookBoxRoutes(server: MyFastifyInstance) {
    server.get('/bookboxes/:bookboxId', { schema: getBookboxSchema }, getBookbox);
    server.get('/bookboxes/search', { schema: searchBookboxesSchema }, searchBookboxes);
    server.post('/bookboxes/new', { preValidation: [server.adminAuthenticate], schema: addNewBookboxSchema }, addNewBookbox);
    server.delete('/bookboxes/:bookboxId/books/:bookId', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: getBookFromBookBoxSchema }, getBookFromBookBox);
    server.post('/bookboxes/:bookboxId/books/add', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: addBookToBookboxSchema }, addBookToBookbox);
    server.delete('/bookboxes/:bookboxId', { preValidation: [server.adminAuthenticate], schema: deleteBookBoxSchema }, deleteBookBox);
    server.put('/bookboxes/:bookboxId', { preValidation: [server.adminAuthenticate], schema: updateBookBoxSchema }, updateBookBox);
}
