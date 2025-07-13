import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import TransactionService from "../services/transaction.service";
import { createCustomTransactionSchema, getTransactionHistorySchema } from "../schemas/transaction.schemas";

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

async function getTransactionHistory(request: FastifyRequest, reply: FastifyReply) {
    try {
        const transactions = await TransactionService.getTransactionHistory(request as { query: { username?: string; bookTitle?: string; bookboxId?: string; limit?: number } });
        reply.send({transactions});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
} 


interface MyFastifyInstance extends FastifyInstance {
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}

export default async function transactionRoutes(server: MyFastifyInstance) {
    server.get('/books/transactions', { schema: getTransactionHistorySchema }, getTransactionHistory);
    server.post('/transactions/custom', { 
        preValidation: [server.adminAuthenticate]
    }, createCustomTransaction);


    server.delete('/transactions/clear', {
        preValidation: [server.adminAuthenticate]
    }, async (request: FastifyRequest, reply: FastifyReply) => {
        try {
            await TransactionService.clearCollection();
            reply.send({ message: 'Transactions cleared' });
        } catch (error: unknown) {
            const statusCode = (error as any).statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
