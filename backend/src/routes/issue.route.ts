import { FastifyReply, FastifyRequest } from "fastify";
import { AuthenticatedRequest, MyFastifyInstance } from "../types";
import { closeIssueSchema, createIssueSchema, getIssueSchema, investigateIssueSchema, reopenIssueSchema } from "../schemas";
import { UserService, IssueService } from "../services";

async function createIssue(request: FastifyRequest, reply: FastifyReply) {
    try {
        const user = (request as AuthenticatedRequest).user; 
        const userId = user?.id || undefined;
        
        let username, email;
        
        if (!userId) {
            // Get email from request body if user is not authenticated
            email = (request as { body: { email: string } }).body.email;
            username = 'guest'; // Default username for unauthenticated users
        } else {
            // Use the authenticated user's email
            const user = await UserService.getUser(userId);
            email = user?.email;
            username = user?.username;
        }

        if (!email) {
            reply.code(400).send({ error: 'Email is required' });
            return;
        }

        const { bookboxId, subject, description } = request.body as { 
            bookboxId: string; 
            subject: string; 
            description: string 
        };
        const issue = await IssueService.createIssue({username, email, bookboxId, subject, description});
        reply.code(201).send(issue);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function getIssue(request: FastifyRequest, reply: FastifyReply) {
    try {
        const issueId = (request as { params: { id: string } }).params.id;
        const issue = await IssueService.getIssue(issueId);
        reply.send(issue);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function investigateIssue(request: FastifyRequest, reply: FastifyReply) {
    try {
        const issueId = (request as { params: { id: string } }).params.id;
        const issue = await IssueService.investigateIssue(issueId);
        reply.send(issue);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function closeIssue(request: FastifyRequest, reply: FastifyReply) {
    try {
        const issueId = (request as { params: { id: string } }).params.id;
        const issue = await IssueService.closeIssue(issueId);
        reply.send(issue);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function reopenIssue(request: FastifyRequest, reply: FastifyReply) {
    try {
        const issueId = (request as { params: { id: string } }).params.id;
        const issue = await IssueService.reopenIssue(issueId);
        reply.send(issue);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
} 

export default async function issueRoutes(server: MyFastifyInstance) {
    server.post('/issues', { preValidation: [server.optionalAuthenticate], schema: createIssueSchema }, createIssue);
    server.get('/issues/:id', { schema: getIssueSchema }, getIssue);
    server.put('/issues/:id/investigate', { preValidation: [server.adminAuthenticate], schema: investigateIssueSchema }, investigateIssue);
    server.put('/issues/:id/close', { preValidation: [server.adminAuthenticate], schema: closeIssueSchema }, closeIssue);
    server.put('/issues/:id/reopen', { preValidation: [server.adminAuthenticate], schema: reopenIssueSchema }, reopenIssue);
}