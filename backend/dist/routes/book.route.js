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
exports.default = bookRoutes;
const book_service_1 = __importDefault(require("../services/book.service"));
const utilities_1 = require("../services/utilities");
function getBookInfoFromISBN(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const book = yield book_service_1.default.getBookInfoFromISBN(request);
            reply.send(book);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
const searchBooksSchema = {
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
function sendBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.requestBookToUsers(request);
            reply.code(201).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
function deleteBookRequest(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield book_service_1.default.deleteBookRequest(request);
            reply.code(204).send({ message: 'Book request deleted' });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(404).send({ error: message });
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
function getBookRequests(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield book_service_1.default.getBookRequests(request);
            reply.code(200).send(response);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
const getBookRequestsSchema = {
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
function getTransactionHistory(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const transactions = yield book_service_1.default.getTransactionHistory(request);
            reply.send({ transactions });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
const getTransactionHistorySchema = {
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
function bookRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/books/:id', { schema: getBookSchema }, getBook);
        server.get('/books/info-from-isbn/:isbn', { preValidation: [server.optionalAuthenticate], schema: getBookInfoFromISBNSchema }, getBookInfoFromISBN);
        server.get('/books/search', { schema: searchBooksSchema }, searchBooks);
        server.post('/books/request', { preValidation: [server.authenticate], schema: sendBookRequestSchema }, sendBookRequest);
        server.delete('/books/request/:id', { preValidation: [server.authenticate], schema: deleteBookRequestSchema }, deleteBookRequest);
        server.get('/books/requests', { schema: getBookRequestsSchema }, getBookRequests);
        server.get('/books/transactions', { schema: getTransactionHistorySchema }, getTransactionHistory);
    });
}
