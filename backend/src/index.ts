const Fastify = require('fastify');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const fastifyJwt = require('@fastify/jwt');
const bookRoutes = require('./routes/book.route');
const userRoutes = require('./routes/user.route');
const threadRoutes = require('./routes/thread.route');
const fastifyCors = require('@fastify/cors');


dotenv.config();
const server = Fastify({ logger: { level: 'error' } });
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
    .then(() => console.log('MongoDB connected...'))
    .catch((err: any) => console.error('MongoDB connection error:', err));

// Register routes
server.register(bookRoutes);
server.register(userRoutes);
server.register(threadRoutes);


// Start the server
const port = process.env.PORT || 3000;
const host = ("RENDER" in process.env) ? '0.0.0.0' : 'localhost';
console.log(`Starting server on port ${port}`);
server.listen({host: host, port: port}, (err: any, address: any) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }
    console.log(`Server started on port ${port}`);
});


// Export the server for testing
module.exports = server;