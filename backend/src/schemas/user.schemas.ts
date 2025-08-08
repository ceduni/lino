import { createUserSchema, notificationSchema } from './models.schemas';
import { createResponseSchema, createArrayResponseSchema } from './utils';

export const registerUserSchema = {
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
        }
    },
    response: {
        201: {
            description: 'User registered successfully',
            type: 'object',
            properties: {
                username: { type: 'string' },
                email: { type: 'string' },
                token: { type: 'string' }
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

export const loginUserSchema = {
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
                username: { type: 'string' },
                email: { type: 'string' },
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

export const getUserSchema = {
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
                user: createUserSchema()
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

export const getUserNotificationsSchema = {
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
        200: createResponseSchema({
            notifications: {
                type: 'array', 
                items: notificationSchema
            }
        }, 'User notifications'),
        404: {
            description: 'User not found',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }
};

export const readNotificationSchema = {
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
                    type: 'array', 
                    items: {
                        type: 'object',
                        properties: {
                            _id: { type: 'string' },
                            userId: { type: 'string' },
                            bookId: { type: 'string' },
                            bookTitle: { type: 'string' },
                            bookboxId: { type: 'string' },
                            reason: { 
                                type: 'array', 
                                items: { 
                                    type: 'string',
                                    enum: ['fav_bookbox', 'same_borough', 'fav_genre', 'book_request']
                                }
                            },
                            read: { type: 'boolean' },
                            createdAt: { type: 'string', format: 'date-time' }
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
};

export const updateUserSchema = {
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
            favouriteGenres: { type: 'array', items: { type: 'string' } },
        }
    },
    response: {
        200: {
            description: 'Updated user infos',
            type: 'object',
            properties: {
                user: {
                    type: 'object',
                    properties: {
                        _id: { type: 'string' },
                        username: { type: 'string' },
                        email: { type: 'string' },
                        phone: { type: 'string' },
                        favouriteGenres: { type: 'array', items: { type: 'string' } },
                        favouriteLocations: { 
                            type: 'array',
                            items: {
                                type: 'object',
                                properties: {
                                    _id: { type: 'string' },
                                    latitude: { type: 'number' },
                                    longitude: { type: 'number' },
                                    name: { type: 'string' },
                                    tag: { type: 'string' },
                                    boroughId: { type: 'string' }
                                },
                                required: ['latitude', 'longitude', 'name', 'boroughId']
                            },
                            default: []
                        },
                        numIssuesReported: { type: 'number' },
                        acceptedNotificationTypes: {
                            type: 'object',
                            properties: {
                                addedBook: { type: 'boolean' },
                                bookRequested: { type: 'boolean' }
                            },
                        },
                        numSavedBooks: { type: 'number' },
                        followedBookboxes: { type: 'array', items: { type: 'string' } },
                        createdAt: { type: 'string', format: 'date-time' },
                        isAdmin: { type: 'boolean' }
                    }
                }
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

export const addUserFavLocationSchema = {
    description: 'Add user favourite location',
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
        required: ['latitude', 'longitude', 'name'],
        properties: {
            latitude: { type: 'number', minimum: -90, maximum: 90 },
            longitude: { type: 'number', minimum: -180, maximum: 180 },
            name: { type: 'string' } // Name of the location
        }
    },
    response: {
        200: {
            description: 'Location added to user\'s favourite locations',
            type: 'object',
            properties: {
                longitude: { type: 'number' },
                latitude: { type: 'number' },
                name: { type: 'string' }, // Name of the location
                boroughId: { type: 'string' }, // ID of the borough where the location is
                tag: { type: 'string' } // Optional tag for the location
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

export const deleteUserFavLocationSchema = {
    description: 'Delete user favourite location',
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
        required: ['name'],
        properties: {
            name: { type: 'string' }, // Name of the location to be removed
        }
    },
    response: {
        200: {
            description: 'Location removed from user\'s favourite locations',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        404: {
            description: 'User or location not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};

export const clearCollectionSchema = {
    description: 'Clear collection',
    tags: ['users', 'books', 'thread'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: {type: 'string'} // JWT token
        }
    },
    response: {
        200: {
            description: 'Collection cleared',
            type: 'object',
            properties: {
                message: {type: 'string'}
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

export const toggleAcceptedNotificationTypeSchema = {
    description: 'Toggle accepted notification type',
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
        required: ['type'],
        properties: {
            type: { type: 'string', enum: ['addedBook', 'bookRequested'] },
        }
    },
    response: {
        200: {
            description: 'Notification type toggled',
            type: 'object',
            properties: {
                type: { type: 'string', enum: ['addedBook', 'bookRequested'] },
                enabled: { type: 'boolean' }
            }
        },
        400: {
            description: 'Invalid notification type',
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
