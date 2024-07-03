import {FastifyInstance, FastifyReply, FastifyRequest, RouteGenericInterface} from 'fastify';
import userService from '../services/user.service';
import UserService from "../services/user.service";
import User from "../models/user.model";



async function registerUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const response = await userService.registerUser(request.body);
        reply.code(201).send(response);
    } catch (error : any) {
        reply.code(400).send({ error: error.message });
    }
}

async function loginUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const response = await userService.loginUser(request.body);
        reply.send({ token : response.token });
    } catch (error) {
        reply.code(401).send({ error: 'Invalid credentials' });
    }
}


async function addToFavorites(request : FastifyRequest, reply : FastifyReply) {
    try {
        // @ts-ignore
        const userId = request.user.id;  // Extract user ID from JWT token
        // @ts-ignore
        const bookId = request.body.bookId;
        const user = await UserService.addToFavorites(userId, bookId);
        if (!user) {
            return;
        }
        reply.code(200).send({ favorites : user.favoriteBooks });
    } catch (error) {
        reply.code(500).send({ error: 'Internal server error' });
    }
}


async function removeFromFavorites(request : FastifyRequest, reply : FastifyReply) {
    try {
        // @ts-ignore
        const userId = request.user.id;  // Extract user ID from JWT token
        // @ts-ignore
        const  id = request.params.id;
        const user = await UserService.removeFromFavorites(userId, id);
        // @ts-ignore
        reply.send({ favorites : user.favoriteBooks });
    } catch (error) {
        reply.code(500).send({ error: 'Internal server error' });
    }
}


async function getUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        // @ts-ignore
        const userId = request.user.id;  // Extract user ID from JWT token
        const user = await User.findById(userId);
        reply.send({ user: user });
    } catch (error) {
        reply.code(500).send({ error: 'Internal server error' });
    }
}

async function getUserFavorites(request : FastifyRequest, reply : FastifyReply) {
    try {
        // @ts-ignore
        const userId = request.user.id;  // Extract user ID from JWT token
        const favorites = await UserService.getFavorites(userId);
        reply.send({ favorites : favorites });
    } catch (error) {
        reply.code(500).send({ error: 'Internal server error' });
    }

}

async function updateUser(request : FastifyRequest, reply : FastifyReply) {
    try {
        const user = await UserService.updateUser(request);
        reply.send({ user: user });
    } catch (error : any) {
        reply.code(401).send({ error: error.message });
    }
}

async function clearCollection(request : FastifyRequest, reply : FastifyReply) {
    await UserService.clearCollection();
    reply.send({message: 'Users cleared'});

}


interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function userRoutes(server: MyFastifyInstance) {
    server.get('/users', { preValidation: [server.authenticate] }, getUser);
    server.get('/users/favorites', { preValidation: [server.authenticate] }, getUserFavorites);
    server.post('/users/register', registerUser);
    server.post('/users/login', loginUser);
    server.post('/users/update', { preValidation: [server.authenticate] }, updateUser);
    server.post('/users/favorites', { preValidation: [server.authenticate] }, addToFavorites);
    server.delete('/users/favorites/:id', { preValidation: [server.authenticate] }, removeFromFavorites);
    server.delete('/users/clear', { preValidation: [server.adminAuthenticate] }, clearCollection);
}