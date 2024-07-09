import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from "fastify";
import BookService from "../services/book.service";
import {bookSchema, clearCollectionSchema} from "../services/utilities";

async function addBookToBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.addBook(request);
        reply.code(201).send(response);
    } catch (error : any) {
        reply.code(error.statusCode).send({error: error.message});
    }
}

const addBookToBookboxSchema = {
    description: 'Add a book to a bookbox',
    tags: ['books', 'bookboxes'],
    body: {
        type: 'object',
        properties: {
            qrCodeId: { type: 'string' },
            bookboxId: { type: 'string' },
            title: { type: 'string' },
            authors: { type: 'array', items: { type: 'string' } },
            isbn: { type: 'string' },
            description: { type: 'string' },
            coverImage: { type: 'string' },
            publisher: { type: 'string' },
            categories: { type: 'array', items: { type: 'string' } },
            parutionYear: { type: 'number' },
            pages: { type: 'number' }
        },
        required: ['qrCodeId', 'bookboxId'],
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        },
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
        }
    }
};


async function getBookFromBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.getBookFromBookBox(request);
        reply.send(response);
    } catch (error : any) {
        reply.code(error.statusCode).send({error: error.message});
    }
}
const getBookFromBookBoxSchema = {
    description: 'Get book from bookbox',
    tags: ['books', 'bookboxes'],
    params: {
        type: 'object',
        properties: {
            bookQRCode: { type: 'string' },
            bookboxId: { type: 'string' }
        },
        required: ['bookQRCode', 'bookboxId']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        },
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
        }
    }
};


interface Params extends RouteGenericInterface {
    Params: {
        isbn: string
    }
}
async function getBookInfoFromISBN(request: FastifyRequest<Params>, reply: FastifyReply) {
    try {
        const book = await BookService.getBookInfoFromISBN(request);
        reply.send(book);
    } catch (error : any) {
        reply.code(error.statusCode).send({error: error.message});
    }
}
const getBookInfoFromISBNSchema = {
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
                parutionYear: {type: 'number'},
                pages: {type: 'number'}
            }
        },
        404: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};

async function searchBooks(request: FastifyRequest, reply: FastifyReply) {
    try {
        const books = await BookService.searchBooks(request);
        reply.send({books : books});
    } catch (error : any) {
        reply.code(error.statusCode).send({error: error.message});
    }
}

const searchBooksSchema = {
    description: 'Search books',
    tags: ['books'],
    querystring: {
        type: 'object',
        properties: {
            cat: {type: 'array', items: {type: 'string'}},
            kw: {type: 'string'},
            pmt: {type: 'boolean'},
            pg: {type: 'number'},
            bf: {type: 'boolean'},
            py: {type: 'number'},
            pub: {type: 'string'},
            bbid: {type: 'string'},
            cls: {type: 'string'},
            asc: {type: 'boolean'},
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
                            ...bookSchema.properties,
                            bookboxPresence: { type: 'array', items: { type: 'string' } }
                        }
                    }
                }
            }
        },
        404: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }
};

async function sendAlert(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.alertUsers(request);
        reply.send(response);
    } catch (error : any) {
        reply.code(error.statusCode).send({error: error.message});
    }
}

const sendAlertSchema = {
    description: 'Send alert',
    tags: ['books', 'users'],
    body: {
        type: 'object',
        properties: {
            title: { type: 'string' },
        },
        required: ['title']
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
            description: 'Alert sent',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        400: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};


interface GetUniqueBookParams extends RouteGenericInterface {
    Params: {
        id: string
    }
}
async function getBook(request: FastifyRequest<GetUniqueBookParams>, reply: FastifyReply) {
    try {
        const book = await BookService.getBook(request.params.id);
        reply.send(book);
    } catch (error : any) {
        reply.code(404).send({error: error.message});
    }
}

const getBookSchema = {
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
        const response = await BookService.getBookBox(request.params.bookboxId);
        reply.send(response);
    } catch (error : any) {
        reply.code(404).send({error: error.message});
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
                location: { type: 'array', items: { type: 'number' } },
                infoText: { type: 'string' },
                books: { type: 'array', items: bookSchema }
            }
        },
        404: {
            description: 'Error message',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};


async function addNewBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const response = await BookService.addNewBookbox(request);
        reply.code(201).send(response);
    } catch (error : any) {
        reply.code(400).send({error: error.message});
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
        },
        required: ['name', 'infoText', 'latitude', 'longitude'],
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
                location: { type: 'array', items: { type: 'number' } },
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
        }
    }
};


async function searchBookboxes(request: FastifyRequest, reply: FastifyReply) {
    try {
        const bookboxes = await BookService.searchBookboxes(request);
        reply.send({bookboxes : bookboxes});
    } catch (error : any) {
        reply.code(400).send({error: error.message});
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
                            location: { type: 'array', items: { type: 'number' } },
                            infoText: { type: 'string' },
                            books: { type: 'array', items: bookSchema }
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
        }
    }
}

async function clearCollection(request: FastifyRequest, reply: FastifyReply) {
    try {
        await BookService.clearCollection();
        reply.send({message: 'Books cleared'});
    } catch (error : any) {
        reply.code(500).send({error: error.message});
    }
}

interface MyFastifyInstance extends FastifyInstance {
    optionalAuthenticate: (request: FastifyRequest) => void;
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function bookRoutes(server: MyFastifyInstance) {
    server.get('/books/get/:id', { schema : getBookSchema }, getBook);
    server.get('/books/bookbox/:bookboxId', { schema: getBookboxSchema }, getBookbox);
    server.get('/books/:bookQRCode/:bookboxId', { preValidation: [server.optionalAuthenticate], schema: getBookFromBookBoxSchema }, getBookFromBookBox);
    server.get('/books/:isbn', { preValidation: [server.optionalAuthenticate], schema: getBookInfoFromISBNSchema }, getBookInfoFromISBN);
    server.get('/books/search', { schema: searchBooksSchema }, searchBooks);
    server.get('/books/bookbox/search', { schema: searchBookboxesSchema }, searchBookboxes);
    server.post('/books/add', { preValidation: [server.optionalAuthenticate], schema: addBookToBookboxSchema }, addBookToBookbox);
    server.post('/books/alert', { preValidation: [server.authenticate], schema: sendAlertSchema }, sendAlert);
    server.post('/books/bookbox/new', { preValidation: [server.adminAuthenticate], schema: addNewBookboxSchema }, addNewBookbox);
    server.delete('/books/clear', { preValidation: [server.adminAuthenticate], schema: clearCollectionSchema }, clearCollection);
}