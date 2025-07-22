import { paginationSchema } from "../search/search.schemas";

export const searchAdminsSchema = {
    description: 'Search admin users',
    tags: ['admin'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'List of admin users',
            type: 'object',
            properties: {
                admins: {
                    type: 'array',
                    items: {
                        type: 'object', 
                        properties: {
                            _id: { type: 'string' },
                            username: { type: 'string' },
                            createdAt: { type: 'string' }
                        }
                    }
                },
                pagination: paginationSchema
            }
        }
    }
};

export const addAdminSchema = {
    description: 'Add a new admin user',
    tags: ['admin'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' }
        }
    },
    body: {
        type: 'object',
        required: ['username'],
        properties: {
            username: { type: 'string' }
        }
    },
    response: {
        201: {
            description: 'Admin added successfully',
            type: 'object',
            properties: {
                message: { type: 'string' },
                admin: {
                    type: 'object',
                    properties: {
                        username: { type: 'string' },
                        createdAt: { type: 'string' }
                    }
                }
            }
        }
    }
};

export const removeAdminSchema = {
    description: 'Remove an admin user',
    tags: ['admin'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' }
        }
    },
    body: {
        type: 'object',
        required: ['username'],
        properties: {
            username: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Admin removed successfully',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        }
    }
};

export const checkAdminStatusSchema = {
    description: 'Check if current user is an admin',
    tags: ['admin'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'Admin status',
            type: 'object',
            properties: {
                username: { type: 'string' },
                isAdmin: { type: 'boolean' }
            }
        }
    }
};

export const clearAdminsSchema = {
    description: 'Clear all admin users',
    tags: ['admin'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: { type: 'string' }
        }
    },
    response: {
        200: {
            description: 'All admins cleared',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        }
    }
};


// Bookbox Management Schemas
export const addNewBookboxSchema = {
    description: 'Add new bookbox',
    tags: ['admin', 'bookboxes'],
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
                owner: { type: 'string' },
                image: { type: 'string' },
                longitude: { type: 'number' },
                latitude: { type: 'number' },
                boroughId: { type: 'string' },
                infoText: { type: 'string' },
                isActive: { type: 'boolean' },
                books: { type: 'array' }
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

export const updateBookBoxSchema = {
    description: 'Update a bookbox',
    tags: ['admin', 'bookboxes'],
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
        401: {
            description: 'Unauthorized',
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
        }
    }
};

export const deleteBookBoxSchema = {
    description: 'Delete a bookbox',
    tags: ['admin', 'bookboxes'],
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
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Bookbox deleted',
            type: 'object',
            properties: {
                message: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized',
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
        }
    }
};

export const activateBookBoxSchema = {
    description: 'Activate a bookbox',
    tags: ['admin', 'bookboxes'],
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
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Bookbox activated',
            type: 'object',
            properties: {
                message: { type: 'string' },
                bookbox: {
                    type: 'object',
                    properties: {
                        _id: { type: 'string' },
                        name: { type: 'string' },
                        isActive: { type: 'boolean' }
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
        },
        404: {
            description: 'Bookbox not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }    
};

export const deactivateBookBoxSchema = {
    description: 'Deactivate a bookbox',
    tags: ['admin', 'bookboxes'],
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
        required: ['authorization']
    },
    response: {
        200: {
            description: 'Bookbox deactivated',
            type: 'object',
            properties: {
                message: { type: 'string' },
                bookbox: {
                    type: 'object',
                    properties: {
                        _id: { type: 'string' },
                        name: { type: 'string' },
                        isActive: { type: 'boolean' }
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
        },
        404: {
            description: 'Bookbox not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};

export const transferBookBoxOwnershipSchema = {
    description: 'Transfer ownership of a bookbox to another admin',
    tags: ['admin', 'bookboxes'],
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
            newOwner: { type: 'string' }
        },
        required: ['newOwner']
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
            description: 'Bookbox ownership transferred',
            type: 'object',
            properties: {
                message: { type: 'string' },
                bookbox: {
                    type: 'object',
                    properties: {
                        _id: { type: 'string' },
                        name: { type: 'string' },
                        owner: { type: 'string' }
                    }
                }
            }
        },
        400: {
            description: 'Invalid request',
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
        404: {
            description: 'Bookbox or new owner not found',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
