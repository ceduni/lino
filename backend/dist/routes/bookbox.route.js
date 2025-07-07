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
exports.default = bookBoxRoutes;
const bookbox_service_1 = __importDefault(require("../services/bookbox.service"));
const utilities_1 = require("../services/utilities");
function addBookToBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.addBook(request);
            reply.code(201).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
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
function getBookFromBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.getBookFromBookBox(request);
            reply.send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
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
function getBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield bookbox_service_1.default.getBookBox(request.params.bookboxId);
            reply.send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(404).send({ error: message });
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
            const response = yield bookbox_service_1.default.addNewBookbox(request);
            reply.code(201).send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(400).send({ error: message });
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
            const bookboxes = yield bookbox_service_1.default.searchBookboxes(request);
            reply.send({ bookboxes: bookboxes });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(400).send({ error: message });
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
function bookBoxRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/bookboxes/:bookboxId', { schema: getBookboxSchema }, getBookbox);
        server.get('/bookboxes/search', { schema: searchBookboxesSchema }, searchBookboxes);
        server.post('/bookboxes/new', { preValidation: [server.adminAuthenticate], schema: addNewBookboxSchema }, addNewBookbox);
        server.delete('/bookboxes/:bookboxId/books/:bookId', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: getBookFromBookBoxSchema }, getBookFromBookBox);
        server.post('/bookboxes/:bookboxId/books/add', { preValidation: [server.bookManipAuth, server.optionalAuthenticate], schema: addBookToBookboxSchema }, addBookToBookbox);
    });
}
