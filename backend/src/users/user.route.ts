import { FastifyReply, FastifyRequest} from 'fastify';
import UserService from "./user.service";
import User from "./user.model";
import { 
    registerUserSchema,
    loginUserSchema,
    getUserSchema,
    getUserNotificationsSchema,
    readNotificationSchema,
    updateUserSchema,
    addUserFavLocationSchema,
    clearCollectionSchema,
    deleteUserFavLocationSchema,
    toggleAcceptedNotificationTypeSchema
} from "./user.schemas";
import { AuthenticatedRequest, MyFastifyInstance } from "../types/common.types";

async function registerUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const { username, email, phone, password } = request.body as {
            username: string;
            email: string;
            password: string;
            phone?: string;
        }

        const response = await UserService.registerUser(
            username, email, password, phone
        );
        reply.code(201).send(response);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
} 

async function loginUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const { identifier, password } = request.body as {
            identifier: string; // can be either username or email
            password: string;
        }
        const response = await UserService.loginUser(identifier, password);
        reply.send(response);
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
        const userId = (request as AuthenticatedRequest).user.id;  
        const notifications = await UserService.getUserNotifications(userId);
        reply.send({ notifications });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function readNotification(request : FastifyRequest, reply : FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id;
        const { notificationId } = request.body as { notificationId: string };
        const notifications = await UserService.readNotification(userId, notificationId);
        reply.code(200).send({ notifications });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function updateUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id;
        const { username, password, email, phone, favouriteGenres } = request.body as {
            username?: string;
            password?: string;
            email?: string;
            phone?: string;
            favouriteGenres?: string[];
        };
        const user = await UserService.updateUser(
            userId, username, password, email, phone, favouriteGenres
        );
        reply.send({ user });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function addUserFavLocation(request : FastifyRequest, reply : FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id;
        const { latitude, longitude, name, tag } = request.body as {
            latitude: number;
            longitude: number;
            name: string;
            tag?: string; // Optional tag for the location
        };
        const result = await UserService.addUserFavLocation(
            userId, latitude, longitude, name, tag
        );
        reply.send(result);
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function deleteUserFavLocation(request : FastifyRequest, reply : FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id;
        const { name } = request.body as { name: string };
        await UserService.deleteUserFavLocation(userId, name);
        reply.send({ message: 'Location removed from favourites' });
    } catch (error : unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function toggleAcceptedNotificationType(request : FastifyRequest, reply : FastifyReply) {
    try {
        const userId = (request as AuthenticatedRequest).user.id;
        const { type } = request.body as { type: string; };
        const user = await UserService.toggleAcceptedNotificationType(userId, type);
        reply.send({ user });
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

 
export default async function userRoutes(server: MyFastifyInstance) {
    server.get('/users', { preValidation: [server.authenticate], schema : getUserSchema }, getUser);
    server.get('/users/notifications', { preValidation: [server.authenticate], schema : getUserNotificationsSchema }, getUserNotifications);
    server.post('/users/notifications/read', { preValidation: [server.authenticate], schema : readNotificationSchema }, readNotification);
    server.post('/users/register', { schema : registerUserSchema }, registerUser);
    server.post('/users/login', { schema : loginUserSchema }, loginUser);
    server.post('/users/update', { preValidation: [server.authenticate], schema : updateUserSchema }, updateUser);
    server.post('/users/location', { preValidation: [server.authenticate], schema : addUserFavLocationSchema }, addUserFavLocation);
    server.delete('/users/location', { preValidation: [server.authenticate], schema : deleteUserFavLocationSchema }, deleteUserFavLocation);
    server.put('/users/notifications/toggle', { preValidation: [server.authenticate], schema : toggleAcceptedNotificationTypeSchema }, toggleAcceptedNotificationType);
    server.delete('/users/clear', { preValidation: [server.superAdminAuthenticate], schema : clearCollectionSchema }, clearCollection);
    server.delete('/users/notifications/clear', { preValidation: [server.superAdminAuthenticate] }, async (request: FastifyRequest, reply: FastifyReply) => {
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
