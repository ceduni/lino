"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const book_service_1 = __importDefault(require("../services/book.service"));
const utilities_1 = require("../services/utilities");
function addBookToBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.addBook(request);
            reply.code(201).send(response);
        }
        catch (error) {
            console.log(error);
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
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
            parutionYear: { type: "number" },
            pages: { type: "number" }
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
function getBookFromBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.getBookFromBookBox(request);
            reply.send(response);
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
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
                book: utilities_1.bookSchema,
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
function getBookInfoFromISBN(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const book = yield book_service_1.default.getBookInfoFromISBN(request);
            reply.send(book);
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
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
function searchBooks(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const books = yield book_service_1.default.searchBooks(request);
            reply.send({ books: books });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const searchBooksSchema = {
    description: 'Search books',
    tags: ['books'],
    querystring: {
        type: 'object',
        properties: {
            cat: { type: 'array', items: { type: 'string' } },
            kw: { type: 'string' },
            pmt: { type: 'boolean' },
            pg: { type: 'number' },
            bf: { type: 'boolean' },
            py: { type: 'number' },
            pub: { type: 'string' },
            bbid: { type: 'string' },
            cls: { type: 'string' },
            asc: { type: 'boolean' },
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
                        properties: Object.assign(Object.assign({}, utilities_1.bookSchema.properties), { bookboxPresence: { type: 'array', items: { type: 'string' } } })
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
function sendBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.requestBookToUsers(request);
            reply.code(201).send(response);
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const sendBookRequestSchema = {
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
                isFulfilled: { type: 'boolean' }
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
function deleteBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield book_service_1.default.deleteBookRequest(request);
            reply.code(204).send({ message: 'Book request deleted' });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const deleteBookRequestSchema = {
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
function getBook(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const book = yield book_service_1.default.getBook(request.params.id);
            reply.send(book);
        }
        catch (error) {
            reply.code(404).send({ error: error.message });
        }
    });
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
        200: Object.assign({ description: 'Book found' }, utilities_1.bookSchema),
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
function getBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.getBookBox(request.params.bookboxId);
            reply.send(response);
        }
        catch (error) {
            reply.code(404).send({ error: error.message });
        }
    });
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
                image: { type: 'string' },
                books: { type: 'array', items: utilities_1.bookSchema }
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
function addNewBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.addNewBookbox(request);
            reply.code(201).send(response);
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
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
                location: { type: 'array', items: { type: 'number' } },
                image: { type: 'string' },
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
function searchBookboxes(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const bookboxes = yield book_service_1.default.searchBookboxes(request);
            reply.send({ bookboxes: bookboxes });
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
        }
    });
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
                            image: { type: 'string' },
                            books: { type: 'array', items: utilities_1.bookSchema }
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
function getBookRequests(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.getBookRequests(request);
            reply.code(200).send(response);
        }
        catch (error) {
            reply.code(500).send({ error: error.message });
        }
    });
}
const getBookRequestsSchema = {
    description: 'Get book requests',
    tags: ['books', 'users'],
    querystring: {
        type: 'object',
        properties: {
            status: { type: 'string' }
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
                    isFulfilled: { type: 'boolean' }
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
function clearCollection(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield book_service_1.default.clearCollection();
            reply.send({ message: 'Books cleared' });
        }
        catch (error) {
            reply.code(500).send({ error: error.message });
        }
    });
}
function bookRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/books/get/:id', { schema: getBookSchema }, getBook);
        server.get('/books/bookbox/:bookboxId', { schema: getBookboxSchema }, getBookbox);
        server.get('/books/:bookQRCode/:bookboxId', { preValidation: [server.optionalAuthenticate], schema: getBookFromBookBoxSchema }, getBookFromBookBox);
        server.get('/books/:isbn', { preValidation: [server.optionalAuthenticate], schema: getBookInfoFromISBNSchema }, getBookInfoFromISBN);
        server.get('/books/search', { schema: searchBooksSchema }, searchBooks);
        server.get('/books/bookbox/search', { schema: searchBookboxesSchema }, searchBookboxes);
        server.post('/books/add', { preValidation: [server.optionalAuthenticate], schema: addBookToBookboxSchema }, addBookToBookbox);
        server.post('/books/request', { preValidation: [server.authenticate], schema: sendBookRequestSchema }, sendBookRequest);
        server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: deleteBookRequestSchema }, deleteBookRequest);
        server.get('/books/requests', { schema: getBookRequestsSchema }, getBookRequests);
        server.post('/books/bookbox/new', { preValidation: [server.adminAuthenticate], schema: addNewBookboxSchema }, addNewBookbox);
        server.delete('/books/clear', { preValidation: [server.adminAuthenticate], schema: utilities_1.clearCollectionSchema }, clearCollection);
    });
}
exports.default = bookRoutes;
