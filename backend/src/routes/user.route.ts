import { FastifyInstance } from 'fastify';
import userService from '../services/user.service';
import UserService from "../services/user.service";

export default async function userRoutes(server: FastifyInstance) {
    // API Endpoint: Register User
    server.post('/user/register', async (request, reply) => {
        try {
            const user = await userService.registerUser(request.body);
            reply.send(user.username);
        } catch (error) {
            console.error('Error registering user:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Login User
    server.post('/user/login', async (request, reply) => {
        try {
            const { token } = await userService.loginUser(request.body);
            reply.send({ token });
        } catch (error) {
            console.error('Error logging in user:', error);
            reply.code(401).send({ error: 'Invalid credentials' });
        }
    });


    // API Endpoint: Add Book to Favorites (protected route)
    // @ts-ignore
    server.post('/user/favorites/:id', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id.toString();  // Extract user ID from JWT token
            // @ts-ignore
            const { id } = request.params;
            const user = await UserService.addToFavorites(userId, id);
            reply.send(user.favoriteBooks);
        } catch (error) {
            console.error('Error adding book to favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Remove Book from Favorites (protected route)
    // @ts-ignore
    server.delete('/user/favorites/:id', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { id } = request.params;
            const user = await UserService.removeFromFavorites(userId, id);
            reply.send(user.favoriteBooks);
        } catch (error) {
            console.error('Error removing book from favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
