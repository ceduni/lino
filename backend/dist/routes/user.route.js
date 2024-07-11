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
const user_service_1 = __importDefault(require("../services/user.service"));
const user_service_2 = __importDefault(require("../services/user.service"));
const user_model_1 = __importDefault(require("../models/user.model"));
const utilities_1 = require("../services/utilities");
function registerUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield user_service_1.default.registerUser(request.body);
            reply.code(201).send(response);
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const registerUserSchema = {
    description: 'Register a new user',
    tags: ['users'],
    body: {
        type: 'object',
        required: ['username', 'password', 'email'],
        properties: {
            username: { type: 'string' },
            password: { type: 'string' },
            email: { type: 'string' },
            phone: { type: 'string' },
            getAlerted: { type: 'boolean' },
        }
    },
    response: {
        201: {
            description: 'User registered successfully',
            type: 'object',
            properties: {
                username: { type: 'string' },
                password: { type: 'string' }
            }
        },
        400: {
            description: 'Problem in the request : missing or invalid fields',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function loginUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield user_service_1.default.loginUser(request.body);
            reply.send({ token: response.token });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const loginUserSchema = {
    description: 'Login a user',
    tags: ['users'],
    body: {
        type: 'object',
        required: ['identifier', 'password'],
        properties: {
            identifier: { type: 'string' }, // can be either username or email
            password: { type: 'string' }
        },
    },
    response: {
        200: {
            description: 'User logged in successfully',
            type: 'object',
            properties: {
                user: utilities_1.userSchema,
                token: { type: 'string' }
            }
        },
        400: {
            description: 'Invalid credentials',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    },
};
function addToFavorites(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield user_service_2.default.addToFavorites(request);
            reply.code(200).send({ favorites: user.favoriteBooks });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const addToFavoritesSchema = {
    description: 'Add a book to user favorites',
    tags: ['users', 'books'],
    body: {
        type: 'object',
        required: ['bookId'],
        properties: {
            bookId: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Book added to favorites',
            type: 'object',
            properties: {
                favorites: { type: 'array', items: { type: 'string' } }
            }
        },
        404: {
            description: 'User not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        400: {
            description: 'Book already in favorites',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function removeFromFavorites(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield user_service_2.default.removeFromFavorites(request);
            // @ts-ignore
            reply.send({ favorites: user.favoriteBooks });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const removeFromFavoritesSchema = {
    description: 'Remove a book from user favorites',
    tags: ['users', 'books'],
    params: {
        type: 'object',
        required: ['id'],
        properties: {
            id: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Book removed from favorites',
            type: 'object',
            properties: {
                favorites: { type: 'array', items: { type: 'string' } }
            }
        },
        404: {
            description: 'User or book not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function getUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            const user = yield user_model_1.default.findById(userId);
            reply.send({ user: user });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const getUserSchema = {
    description: 'Get user infos',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' } // JWT token
        }
    },
    response: {
        200: {
            description: 'User infos',
            type: 'object',
            properties: {
                user: utilities_1.userSchema
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
function readUserNotifications(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const notifications = yield user_service_2.default.readUserNotifications(request);
            reply.send({ notifications: notifications });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const getUserNotificationsSchema = {
    description: 'Get user notifications',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' } // JWT token
        }
    },
    response: {
        200: {
            description: 'User notifications',
            type: 'object',
            properties: {
                notifications: {
                    type: 'array', items: {
                        type: 'object',
                        properties: {
                            timestamp: { type: 'string' },
                            content: { type: 'string' },
                            read: { type: 'boolean' }
                        }
                    }
                }
            }
        },
        404: {
            description: 'User not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
function getUserFavorites(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            const favorites = yield user_service_2.default.getFavorites(userId);
            reply.send({ favorites: favorites });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const getUserFavoritesSchema = {
    description: 'Get user favorite books',
    tags: ['users', 'books'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' } // JWT token
        }
    },
    response: {
        200: {
            description: 'User favorite books',
            type: 'object',
            properties: {
                favorites: { type: 'array', items: utilities_1.bookSchema }
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
function updateUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield user_service_2.default.updateUser(request);
            reply.send({ user: user });
        }
        catch (error) {
            reply.code(error.statusCode).send({ error: error.message });
        }
    });
}
const updateUserSchema = {
    description: 'Update user infos',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' } // JWT token
        }
    },
    body: {
        type: 'object',
        properties: {
            username: { type: 'string' },
            email: { type: 'string' },
            password: { type: 'string' },
            phone: { type: 'string' },
            getAlerted: { type: 'boolean' },
            keyWords: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Updated user infos',
            type: 'object',
            properties: {
                user: utilities_1.userSchema
            }
        },
        401: {
            description: 'Unauthorized',
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
            yield user_service_2.default.clearCollection();
            reply.send({ message: 'Users cleared' });
        }
        catch (error) {
            reply.code(500).send({ error: error.message });
        }
    });
}
function userRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/users', { preValidation: [server.authenticate], schema: getUserSchema }, getUser);
        server.get('/users/favorites', { preValidation: [server.authenticate], schema: getUserFavoritesSchema }, getUserFavorites);
        server.get('/users/notifications', { preValidation: [server.authenticate], schema: getUserNotificationsSchema }, readUserNotifications);
        server.post('/users/register', { schema: registerUserSchema }, registerUser);
        server.post('/users/login', { schema: loginUserSchema }, loginUser);
        server.post('/users/update', { preValidation: [server.authenticate], schema: updateUserSchema }, updateUser);
        server.post('/users/favorites', { preValidation: [server.authenticate], schema: addToFavoritesSchema }, addToFavorites);
        server.delete('/users/favorites/:id', { preValidation: [server.authenticate], schema: removeFromFavoritesSchema }, removeFromFavorites);
        server.delete('/users/clear', { preValidation: [server.adminAuthenticate], schema: utilities_1.clearCollectionSchema }, clearCollection);
    });
}
exports.default = userRoutes;
