import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import TransactionService from "./transaction.service";
import { MyFastifyInstance } from "../types";

async function createCustomTransaction(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { username, action, bookTitle, bookboxId, day, hour } = request.body as {
            username: string;
            action: 'added' | 'took';
            bookTitle: string;
            bookboxId: string;
            day: string; // Format: AAAA-MM-DD
            hour: string; // Format: HH:MM
        };
        const transaction = await TransactionService.createCustomTransaction(
            username, action, bookTitle, bookboxId, day, hour
        );
        reply.code(201).send(transaction);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 400;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

export default async function transactionRoutes(server: MyFastifyInstance) {
    server.post('/transactions/custom', { 
        preValidation: [server.superAdminAuthenticate]
    }, createCustomTransaction);


    server.delete('/transactions/clear', {
        preValidation: [server.superAdminAuthenticate]
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
