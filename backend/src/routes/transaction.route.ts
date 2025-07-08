import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import TransactionService from "../services/transaction.service";
import { createCustomTransactionSchema } from "../schemas/transaction.schemas";

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


interface MyFastifyInstance extends FastifyInstance {
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}

export default async function transactionRoutes(server: MyFastifyInstance) {
    server.post('/transactions/custom', { 
        schema: createCustomTransactionSchema,
        preValidation: [server.adminAuthenticate]
    }, createCustomTransaction);
}
