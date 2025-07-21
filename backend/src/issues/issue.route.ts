import { FastifyReply, FastifyRequest } from "fastify";
import IssueService from "./issue.service";
import { AuthenticatedRequest, MyFastifyInstance } from "../types";
import { closeIssueSchema, createIssueSchema, getIssueSchema, investigateIssueSchema } from "./issue.schemas";

async function createIssue(request: FastifyRequest, reply: FastifyReply) {
    try {
        const issue = await IssueService.createIssue(request as AuthenticatedRequest & 
            { body: { bookboxId: string; subject: string; description: string } });
        reply.send(issue);
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

export default async function issueRoutes(server: MyFastifyInstance) {
    server.post('/issues', { preValidation: [server.authenticate], schema: createIssueSchema }, createIssue);
    server.get('/issues/:id', { schema: getIssueSchema }, getIssue);
    server.put('/issues/:id/investigate', { preValidation: [server.adminAuthenticate], schema: investigateIssueSchema }, investigateIssue);
    server.put('/issues/:id/close', { preValidation: [server.adminAuthenticate], schema: closeIssueSchema }, closeIssue);
}