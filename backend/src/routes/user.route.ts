import {FastifyInstance, FastifyReply, FastifyRequest} from 'fastify';
import userService from '../services/user.service';
import UserService from "../services/user.service";
import User from "../models/user.model";
import { userSchema, clearCollectionSchema } from "../services/utilities";
import { UserRegistrationData, UserLoginCredentials } from "../types/user.types";
import { AuthenticatedRequest } from "../types/common.types";

async function registerUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const response = await userService.registerUser(request.body as UserRegistrationData);
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
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

async function loginUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const response = await userService.loginUser(request.body as UserLoginCredentials);
        reply.send({ token : response.token });
    } catch (error : unknown ) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
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
                user: userSchema,
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


async function getUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const authRequest = request as AuthenticatedRequest;
        const userId = authRequest.user.id;  // Extract user ID from JWT token
        const user = await User.findById(userId);
        reply.send({ user: user });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

const getUserSchema = {
    description: 'Get user infos',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: {type: 'string'} // JWT token
        }
    },
    response: {
        200: {
            description: 'User infos',
            type: 'object',
            properties: {
                user: userSchema
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

async function getUserNotifications(request : FastifyRequest, reply : FastifyReply) {
    try {
        const notifications = await UserService.getUserNotifications(request as AuthenticatedRequest);
        reply.send({ notifications : notifications });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

const getUserNotificationsSchema = {
    description: 'Get user notifications',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: {type: 'string'} // JWT token
        }
    },
    response: {
        200: {
            description: 'User notifications',
            type: 'object',
            properties: {
                notifications: {
                    type: 'array', items:
                        {
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
                error: {type: 'string'}
            }
        }
    }
}

async function readNotification(request : FastifyRequest, reply : FastifyReply) {
    try {
        const notifications = await UserService.readNotification(request as AuthenticatedRequest & { body: { notificationId: string } });
        reply.code(200).send({ notifications : notifications });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

const readNotificationSchema = {
    description: 'Read a user notification',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: {type: 'string'} // JWT token
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
                    type: 'array', items:
                        {
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
                error: {type: 'string'}
            }
        }
    }
}


async function updateUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const user = await UserService.updateUser(request as AuthenticatedRequest & { 
            body: { 
                username?: string; 
                password?: string; 
                email?: string; 
                phone?: string; 
                getAlerted?: boolean; 
                keyWords?: string; 
            } 
        });
        reply.send({ user: user });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

const updateUserSchema = {
    description: 'Update user infos',
    tags: ['users'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: {type: 'string'} // JWT token
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
                user: userSchema
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

async function clearCollection(request : FastifyRequest, reply : FastifyReply) {
    try {
        await UserService.clearCollection();
        reply.send({message: 'Users cleared'});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}


interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function userRoutes(server: MyFastifyInstance) {
    server.get('/users', { preValidation: [server.authenticate], schema : getUserSchema }, getUser);
    server.get('/users/notifications', { preValidation: [server.authenticate], schema : getUserNotificationsSchema }, getUserNotifications);
    server.post('/users/notifications/read', { preValidation: [server.authenticate], schema : readNotificationSchema }, readNotification);
    server.post('/users/register', { schema : registerUserSchema }, registerUser);
    server.post('/users/login', { schema : loginUserSchema }, loginUser);
    server.post('/users/update', { preValidation: [server.authenticate], schema : updateUserSchema }, updateUser);
    server.delete('/users/clear', { preValidation: [server.adminAuthenticate], schema : clearCollectionSchema }, clearCollection);
}
