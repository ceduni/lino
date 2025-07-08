export const createCustomTransactionSchema = {
    description: 'Create a fully customized transaction (Admin only)',
    tags: ['transactions', 'admin'],
    body: {
        type: 'object',
        properties: {
            username: { type: 'string' },
            action: { type: 'string', enum: ['added', 'took'] },
            bookTitle: { type: 'string' },
            bookboxId: { type: 'string' },
            day: { 
                type: 'string',
                pattern: '^\\d{4}-\\d{2}-\\d{2}$',
                description: 'Date in format AAAA-MM-DD'
            },
            hour: { 
                type: 'string',
                pattern: '^\\d{2}:\\d{2}$',
                description: 'Time in format HH:MM'
            }
        },
        required: ['username', 'action', 'bookTitle', 'bookboxId', 'day', 'hour']
    },
    response: {
        201: {
            description: 'Transaction created successfully',
            type: 'object',
            properties: {
                _id: { type: 'string' },
                username: { type: 'string' },
                action: { type: 'string' },
                bookTitle: { type: 'string' },
                bookboxId: { type: 'string' },
                timestamp: { type: 'string' },
                __v: { type: 'number' }
            }
        }, 
        400: {
            description: 'Bad request - validation error',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        401: {
            description: 'Unauthorized - admin access required',
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        403: {
            description: 'Forbidden - admin access required',
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
