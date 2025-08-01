"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reopenIssueSchema = exports.closeIssueSchema = exports.investigateIssueSchema = exports.getIssueSchema = exports.createIssueSchema = void 0;
const issueResponseSchema = {
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
    }
};
exports.createIssueSchema = {
    description: 'Create a new issue',
    tags: ['issues'],
    body: {
        type: 'object',
        properties: {
            bookboxId: { type: 'string' },
            subject: { type: 'string', minLength: 1 },
            description: { type: 'string', minLength: 1 }
        },
        required: ['bookboxId', 'subject', 'description']
    },
    headers: {
        type: 'object',
        properties: {
            authorization: { type: 'string' }
        },
    },
    response: {
        201: issueResponseSchema,
        400: { type: 'object', properties: { error: { type: 'string' } } },
        404: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } }
    }
};
exports.getIssueSchema = {
    description: 'Get an issue by ID',
    tags: ['issues'],
    params: {
        type: 'object',
        properties: {
            id: { type: 'string' }
        },
        required: ['id']
    },
    response: {
        200: issueResponseSchema,
        404: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } }
    }
};
exports.investigateIssueSchema = {
    description: 'Investigate an issue',
    tags: ['issues'],
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
        200: issueResponseSchema,
        404: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } }
    }
};
exports.closeIssueSchema = {
    description: 'Close an issue',
    tags: ['issues'],
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
        200: issueResponseSchema,
        404: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } }
    }
};
exports.reopenIssueSchema = {
    description: 'Reopen a resolved issue',
    tags: ['issues'],
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
        200: issueResponseSchema,
        400: { type: 'object', properties: { error: { type: 'string' } } },
        404: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } }
    }
};
