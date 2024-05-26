import Fastify from 'fastify';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import fastifyJwt from '@fastify/jwt';
import bookRoutes from './routes/book.route';
import userRoutes from './routes/user.route';
import threadRoutes from "./routes/thread.routes";

dotenv.config();
const server = Fastify({ logger: true });

// Register JWT plugin
// @ts-ignore
server.register(fastifyJwt, { secret: process.env.JWT_SECRET_KEY });

// Authentication hook
// @ts-ignore
server.decorate('authenticate', async (request, reply) => {
    try {
        await request.jwtVerify();
    } catch (err) {
        reply.send(err);
    }
});

// Connect to MongoDB
const mongoURI = process.env.MONGODB_URI;
// @ts-ignore
mongoose.connect(mongoURI)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('MongoDB connection error:', err));

// Register routes
server.register(bookRoutes);
server.register(userRoutes);
server.register(threadRoutes);

// Start the server
server.listen({ port: 3000 }, (err, address) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }
    console.log(`Server listening at ${address}`);
});
