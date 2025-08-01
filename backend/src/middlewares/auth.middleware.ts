import { FastifyRequest, FastifyReply } from "fastify";
import { FastifyRequestWithJWT } from "../types";
import AdminService from '../services/admin.service';

// Authentication hooks
export const authenticate = async (request: FastifyRequestWithJWT, reply: FastifyReply) => {
    try {
        await request.jwtVerify();
    } catch (err) {
        reply.send(err); // will send an error 401
    }
};

// Book manipulation token validation preValidation
export const bookManipAuth = async (request: FastifyRequest, reply: FastifyReply) => {
    try {
        const bookManipToken = request.headers['bm_token']; // Get custom header
        const predefinedToken = process.env.BOOK_MANIPULATION_TOKEN;

        if (bookManipToken !== predefinedToken) {
            console.log('Invalid book manipulation token:', bookManipToken);
            return reply.status(401).send({ error: 'Unauthorized' });
        }

    } catch (error) {
        return reply.status(401).send({ error: 'Unauthorized' });
    }
};

export const optionalAuthenticate = async (request: FastifyRequestWithJWT, server: any) => {
    try {
        const authHeader = request.headers.authorization;
        if (authHeader) {
            request.user = await server.jwt.verify(authHeader.split(' ')[1]);
        } else {
            request.user = null;
        }
    } catch (error) {
        request.user = null;
    }
};

export const adminAuthenticate = async (request: FastifyRequestWithJWT, reply: FastifyReply, server: any) => {
    try {
        const authHeader = request.headers.authorization;
        if (!authHeader) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        const token = authHeader.split(' ')[1];
        const user = await server.jwt.verify(token) as { username: string };

        const isAdmin = await AdminService.isAdmin(user.username);

        if (!isAdmin) {
            console.log('Non-admin user tried to access admin route: ', user.username);
            reply.status(401).send({ error: 'Unauthorized' });
        }
        
        request.user = user; // Attach user info to request
    } catch (error) {
        reply.status(401).send({ error: 'Unauthorized' });
    }
};

export const superAdminAuthenticate = async (request: FastifyRequestWithJWT, reply: FastifyReply, server: any) => {
    try {
        const authHeader = request.headers.authorization;
        if (!authHeader) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        const token = authHeader.split(' ')[1];
        const user = await server.jwt.verify(token) as { username: string };
        
        if (user.username !== process.env.ADMIN_USERNAME) {
            console.log('Non-super-admin user tried to access super admin route: ', user.username);
            reply.status(401).send({ error: 'Unauthorized' });
        }

        request.user = user; // Attach user info to request
    } catch (error) {
        reply.status(401).send({ error: 'Unauthorized' });
    }
};
