import { FastifyInstance } from 'fastify';
import userService from '../services/user.service';

export default async function userRoutes(server: FastifyInstance) {
    // API Endpoint: Register User
    server.post('/user/register', async (request, reply) => {
        try {
            const user = await userService.registerUser(request.body);
            reply.send(user);
        } catch (error) {
            console.error('Error registering user:', error);
            reply.code(500).send({ error: 'Internal server error' });
        }
    });

    // API Endpoint: Login User
    server.post('/user/login', async (request, reply) => {
        try {
            const { user, token, refreshToken } = await userService.loginUser(request.body);
            reply.send({ user, token, refreshToken });
        } catch (error) {
            console.error('Error logging in user:', error);
            reply.code(401).send({ error: 'Invalid credentials' });
        }
    });


    // API Endpoint: Refresh Access Token
    server.post('/user/refresh-token', async (request, reply) => {
        try {
            // @ts-ignore
            const { refreshToken } = request.body;
            const newToken = await userService.refreshAccessToken(refreshToken);
            reply.send(newToken);
        } catch (error) {
            console.error('Error refreshing access token:', error);
            reply.code(401).send({ error: 'Invalid refresh token' });
        }
    });
}
