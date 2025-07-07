import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import TransactionService from "../services/transaction.service";

interface CreateCustomTransactionBody {
    username: string;
    action: 'added' | 'took';
    bookTitle: string;
    bookboxId: string;
    day: string; // Format: AAAA-MM-DD
    hour: string; // Format: HH:MM
}

async function createCustomTransaction(request: FastifyRequest, reply: FastifyReply) {
    try {
        const body = request.body as CreateCustomTransactionBody;
        const transaction = await TransactionService.createCustomTransaction(body);
        reply.code(201).send(transaction);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 400;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

const createCustomTransactionSchema = {
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

interface MyFastifyInstance extends FastifyInstance {
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}

export default async function transactionRoutes(server: MyFastifyInstance) {
    server.post('/transactions/custom', { 
        schema: createCustomTransactionSchema,
        preValidation: [server.adminAuthenticate]
    }, createCustomTransaction);
}
