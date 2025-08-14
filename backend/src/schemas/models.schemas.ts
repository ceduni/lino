// Schema factory functions that return fresh schema objects
export function createBookSchema() {
    return {
        type: 'object',
        properties: {
            _id: {type: 'string'},
            isbn: {type: 'string'},
            title: {type: 'string'},
            authors: {type: 'array', items: {type: 'string'}},
            description: {type: 'string'},
            coverImage: {type: 'string'},
            publisher: {type: 'string'},
            categories: {type: 'array', items: {type: 'string'}},
            parutionYear: {type: 'number'},
            pages: {type: 'number'},
            dateAdded: {type: 'string', format: 'date-time'},
            bookboxId: {type: 'string'},
            bookboxName: {type: 'string'}
        }
    };
}

export function createUserSchema() {
    return {
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
    };
}

export function createBookboxSchema() {
    return {
        type: 'object',
        properties: {
            _id: {type: 'string'},
            name: {type: 'string'},
            owner: {type: 'string'},
            image: {type: 'string'},
            longitude: {type: 'number'},
            latitude: {type: 'number'},
            boroughId: {type: 'string'},
            booksCount: {type: 'number'},
            infoText: {type: 'string'},
            isActive: {type: 'boolean'},
            books: {
                type: 'array', 
                items: createBookSchema()
            }
        }
    };
}

// Legacy exports for backward compatibility
export const bookSchema = createBookSchema();
export const userSchema = createUserSchema();
export const bookboxSchema = createBookboxSchema();

export const notificationSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        userId: { type: 'string' },
        bookId: { type: 'string' },
        requestId: { type: 'string' },
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
};

export const threadSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        title: { type: 'string' },
        image: { type: 'string' },
        bookTitle: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
        messages: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    _id: { type: 'string' },
                    username: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' },
                    content: { type: 'string' },
                    respondsTo: { type: 'string' },
                    reactions: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                _id: { type: 'string' },
                                username: { type: 'string' },
                                reactIcon: { type: 'string' },
                                timestamp: { type: 'string', format: 'date-time' }
                            }
                        }
                    }
                }
            }
        }
    }
};

export const transactionSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        action: { type: 'string', enum: ['added', 'took'] },
        bookTitle: { type: 'string' },
        bookboxId: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' }
    }
};

export const bookRequestSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        bookTitle: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
        upvoters: { type: 'array', items: { type: 'string' } },
        nbPeopleNotified: { type: 'number' },
        bookboxIds: { type: 'array', items: { type: 'string' } },
        customMessage: { type: 'string' },
        isSolved: { type: 'boolean' }
    }
};

export const issueSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        email: { type: 'string', format: 'email' },
        bookboxId: { type: 'string' },
        subject: { type: 'string', minLength: 1 },
        description: { type: 'string', minLength: 1 },
        status: { type: 'string', enum: ['open', 'in_progress', 'resolved'], default: 'open' },
        reportedAt: { type: 'string', format: 'date-time' },
        resolvedAt: { type: 'string', format: 'date-time', nullable: true }
    },
};
