import Fastify from 'fastify';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import fastifyJwt from '@fastify/jwt';
import bookRoutes from './routes/book.route';
import userRoutes from './routes/user.route';
import threadRoutes from "./routes/thread.routes";
import fastifyCors from "@fastify/cors";


dotenv.config();
const server = Fastify({ logger: true });
server.register(fastifyCors, {
    origin: true,
});

// Register JWT plugin
// @ts-ignore
server.register(fastifyJwt, { secret: process.env.JWT_SECRET_KEY });

// Authentication hook, request must have an Authorization header with a valid JWT
// @ts-ignore
server.decorate('authenticate', async (request, reply) => {
    try {
        request.jwtVerify();
    } catch (err) {
        reply.send(err); // will send an error 401
    }
});

// Optional authentication hook, request can have an Authorization header with a valid JWT
// If not, the user will be null
// @ts-ignore
server.decorate('optionalAuthenticate', async (request) => {
   try {
        // @ts-ignore
       request.user = await server.jwt.verify(request.headers.authorization.split(' ')[1]);
   } catch (error) {
       request.user = null;
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
