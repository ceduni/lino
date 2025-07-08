"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.clearCollectionSchema = exports.updateUserLocationSchema = exports.updateUserSchema = exports.readNotificationSchema = exports.getUserNotificationsSchema = exports.getUserSchema = exports.loginUserSchema = exports.registerUserSchema = void 0;
const models_schemas_1 = require("./models.schemas");
exports.registerUserSchema = {
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
exports.loginUserSchema = {
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
                user: models_schemas_1.userSchema,
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
exports.getUserSchema = {
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
                user: models_schemas_1.userSchema
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
exports.getUserNotificationsSchema = {
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
                    type: 'array',
                    items: models_schemas_1.notificationSchema
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
exports.readNotificationSchema = {
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
                    type: 'array',
                    items: models_schemas_1.notificationSchema
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
exports.updateUserSchema = {
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
            favouriteGenres: { type: 'array', items: { type: 'string' } },
            boroughId: { type: 'string' },
            requestNotificationRadius: { type: 'number', minimum: 0 }
        }
    },
    response: {
        200: {
            description: 'Updated user infos',
            type: 'object',
            properties: {
                user: models_schemas_1.userSchema
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
exports.updateUserLocationSchema = {
    description: 'Update user location and borough ID',
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
        required: ['latitude', 'longitude'],
        properties: {
            latitude: { type: 'number', minimum: -90, maximum: 90 },
            longitude: { type: 'number', minimum: -180, maximum: 180 }
        }
    },
    response: {
        200: {
            description: 'User location updated',
            type: 'object',
            properties: {
                user: models_schemas_1.userSchema,
                boroughId: { type: 'string' }
            }
        },
        400: {
            description: 'Invalid coordinates',
            type: 'object',
            properties: {
                error: { type: 'string' }
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
exports.clearCollectionSchema = {
    description: 'Clear collection',
    tags: ['users', 'books', 'thread'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' } // JWT token
        }
    },
    response: {
        200: {
            description: 'Collection cleared',
            type: 'object',
            properties: {
                message: { type: 'string' }
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
