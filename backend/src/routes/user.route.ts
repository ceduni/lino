import {FastifyInstance, FastifyReply, FastifyRequest} from 'fastify';
import UserService from "../services/user.service";
import User from "../models/user.model";
import { 
    registerUserSchema,
    loginUserSchema,
    getUserSchema,
    getUserNotificationsSchema,
    readNotificationSchema,
    updateUserSchema,
    addUserFavLocationSchema,
    clearCollectionSchema,
    deleteUserFavLocationSchema
} from "../schemas/user.schemas";
import { userSchema } from "../schemas/models.schemas";
import { UserRegistrationData, UserLoginCredentials } from "../types/user.types";
import { AuthenticatedRequest } from "../types/common.types";

async function registerUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const response = await UserService.registerUser(request.body as UserRegistrationData);
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
} 

async function loginUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const response = await UserService.loginUser(request.body as UserLoginCredentials);
        reply.send({ token : response.token });
    } catch (error : unknown ) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function getUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const authRequest = request as AuthenticatedRequest;
        const userId = authRequest.user.id;  // Extract user ID from JWT token
        const user = await User.findById(userId);
        reply.send({ user: user });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function getUserNotifications(request : FastifyRequest, reply : FastifyReply) {
    try {
        const notifications = await UserService.getUserNotifications(request as AuthenticatedRequest);
        reply.send({ notifications : notifications });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function readNotification(request : FastifyRequest, reply : FastifyReply) {
    try {
        const notifications = await UserService.readNotification(request as AuthenticatedRequest & { body: { notificationId: string } });
        reply.code(200).send({ notifications : notifications });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function updateUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const user = await UserService.updateUser(request as AuthenticatedRequest & { 
            body: { 
                username?: string; 
                password?: string; 
                email?: string; 
                phone?: string; 
                favouriteGenres?: string[];
            } 
        });
        reply.send({ user: user });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function addUserFavLocation(request : FastifyRequest, reply : FastifyReply) {
    try {
        const result = await UserService.addUserFavLocation(request as AuthenticatedRequest & { 
            body: { 
                latitude: number; 
                longitude: number; 
                name: string;
            } 
        });
        reply.send(result);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function deleteUserFavLocation(request : FastifyRequest, reply : FastifyReply) {
    try {
        await UserService.deleteUserFavLocation(request as AuthenticatedRequest & { 
            body: { 
                name: string;
            } 
        });
        reply.send({ message: 'Location removed from favourites' });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function clearCollection(request : FastifyRequest, reply : FastifyReply) {
    try {
        await UserService.clearCollection();
        reply.send({message: 'Users cleared'});
    } catch (error : unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(500).send({error: message});
    }
}


interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function userRoutes(server: MyFastifyInstance) {
    server.get('/users', { preValidation: [server.authenticate], schema : getUserSchema }, getUser);
    server.get('/users/notifications', { preValidation: [server.authenticate], schema : getUserNotificationsSchema }, getUserNotifications);
    server.post('/users/notifications/read', { preValidation: [server.authenticate], schema : readNotificationSchema }, readNotification);
    server.post('/users/register', { schema : registerUserSchema }, registerUser);
    server.post('/users/login', { schema : loginUserSchema }, loginUser);
    server.post('/users/update', { preValidation: [server.authenticate], schema : updateUserSchema }, updateUser);
    server.post('/users/location', { preValidation: [server.authenticate], schema : addUserFavLocationSchema }, addUserFavLocation);
    server.delete('/users/location', { preValidation: [server.authenticate], schema : deleteUserFavLocationSchema }, deleteUserFavLocation);
    server.delete('/users/clear', { preValidation: [server.adminAuthenticate], schema : clearCollectionSchema }, clearCollection);
    server.delete('/users/notifications/clear', { preValidation: [server.adminAuthenticate] }, async (request: FastifyRequest, reply: FastifyReply) => {
        try {
            await UserService.clearNotifications();
            reply.send({ message: 'Notifications cleared' });
        } catch (error: unknown) {
            const statusCode = (error as any).statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
