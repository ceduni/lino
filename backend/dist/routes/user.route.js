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
exports.default = userRoutes;
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
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
function getUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const authRequest = request;
            const userId = authRequest.user.id; // Extract user ID from JWT token
            const user = yield user_model_1.default.findById(userId);
            reply.send({ user: user });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
function getUserNotifications(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const notifications = yield user_service_2.default.getUserNotifications(request);
            reply.send({ notifications: notifications });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
                            _id: { type: 'string' },
                            title: { type: 'string' },
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
function readNotification(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const notifications = yield user_service_2.default.readNotification(request);
            reply.code(200).send({ notifications: notifications });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
const readNotificationSchema = {
    description: 'Read a user notification',
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
        required: ['notificationId'],
        properties: {
            notificationId: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Notification read',
            type: 'object',
            properties: {
                notifications: {
                    type: 'array', items: {
                        type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            title: { type: 'string' },
                            timestamp: { type: 'string' },
                            content: { type: 'string' },
                            read: { type: 'boolean' }
                        }
                    }
                }
            }
        },
        404: {
            description: 'User or notification not found',
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
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
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
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function userRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/users', { preValidation: [server.authenticate], schema: getUserSchema }, getUser);
        server.get('/users/notifications', { preValidation: [server.authenticate], schema: getUserNotificationsSchema }, getUserNotifications);
        server.post('/users/notifications/read', { preValidation: [server.authenticate], schema: readNotificationSchema }, readNotification);
        server.post('/users/register', { schema: registerUserSchema }, registerUser);
        server.post('/users/login', { schema: loginUserSchema }, loginUser);
        server.post('/users/update', { preValidation: [server.authenticate], schema: updateUserSchema }, updateUser);
        server.delete('/users/clear', { preValidation: [server.adminAuthenticate], schema: utilities_1.clearCollectionSchema }, clearCollection);
    });
}
