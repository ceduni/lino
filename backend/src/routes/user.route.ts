import { FastifyInstance } from 'fastify';
import userService from '../services/user.service';
import UserService from "../services/user.service";
import User from "../models/user.model";

export default async function userRoutes(server: FastifyInstance) {
    // API Endpoint: Register User
    server.post('/user/register', async (request, reply) => {
        try {
            const user = await userService.registerUser(request.body);
            reply.send({ username: user.username, password: user.password });
        } catch (error) {
            console.error('Error registering user:', error);
            // @ts-ignore
            reply.code(400).send({ error: error.message });
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
            // @ts-ignore
            reply.send({ favorites : user.favoriteBooks });
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
            // @ts-ignore
            reply.send({ favorites : user.favoriteBooks });
        } catch (error) {
            console.error('Error removing book from favorites:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Add keywords to notifications (protected route)
    // @ts-ignore
    server.post('/user/keywords', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { keywords } = request.body;
            const user = await UserService.parseKeyWords(userId, keywords);
            reply.send({ keywords: user.notificationKeyWords });
        } catch (error) {
            console.error('Error adding keywords to notifications:', error);
            // @ts-ignore
            reply.code(500).send({ error: error.message });
        }
    });

    // API Endpoint: Remove keyword from notifications (protected route)
    // @ts-ignore
    server.delete('/user/keywords/:keyword', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            // @ts-ignore
            const { keyword } = request.params;
            const user = await UserService.removeKeyWord(userId, keyword);
            // @ts-ignore
            reply.send(user.notificationKeyWords);
        } catch (error) {
            console.error('Error removing keyword from notifications:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });


    // API Endpoint: Get user from token (protected route)
    // @ts-ignore
    server.get('/user', { preValidation: [server.authenticate] }, async (request, reply) => {
        try {
            // @ts-ignore
            const userId = request.user.id;  // Extract user ID from JWT token
            const user = await User.findById(userId);
            // @ts-ignore
            reply.send({ user: user });
        } catch (error) {
            console.error('Error getting notifications:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
    // API Endpoint: Clear collection
    // @ts-ignore
    server.delete('/user/clear', async (request, reply) => {
        try {
            await UserService.clearCollection();
            reply.send({ message: 'Collection cleared' });
        } catch (error) {
            console.error('Error clearing collection:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
