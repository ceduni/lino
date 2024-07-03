"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
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
server.decorate('authenticate', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield request.jwtVerify();
    }
    catch (err) {
        reply.send(err); // will send an error 401
    }
}));
// Optional authentication hook, request can have an Authorization header with a valid JWT
// If not, the user will be null
// @ts-ignore
server.decorate('optionalAuthenticate', (request) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // @ts-ignore
        request.user = yield server.jwt.verify(request.headers.authorization.split(' ')[1]);
    }
    catch (error) {
        request.user = null;
    }
}));
// Admin authentication hook, request must have an Authorization header with a valid JWT
// and the user must have a specific username
// @ts-ignore
server.decorate('adminAuthenticate', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const token = request.headers.authorization.split(' ')[1];
        const user = yield server.jwt.verify(token);
        if (user.username !== process.env.ADMIN_USERNAME) {
            reply.status(401).send(new Error('Unauthorized'));
        }
    }
    catch (error) {
        reply.status(401).send(error);
    }
}));
// Connect to MongoDB
const mongoURI = process.env.MONGODB_URI;
// @ts-ignore
mongoose.connect(mongoURI)
    .then(() => __awaiter(void 0, void 0, void 0, function* () {
    console.log('MongoDB connected...');
    // Clear collections and create the admin user after MongoDB connection
    try {
        yield clearCollections();
        yield createAdminUser();
    }
    catch (err) {
        console.error('Error during initialization:', err.message);
    }
}))
    .catch((err) => {
    console.error('MongoDB connection error:', err);
    process.exit(1); // Exit process if MongoDB connection fails
});
// Register routes
server.register(bookRoutes);
server.register(userRoutes);
server.register(threadRoutes);
// Start the server
const port = process.env.PORT || 3000;
const host = ("RENDER" in process.env) ? '0.0.0.0' : 'localhost';
console.log(`Starting server on port ${port} and host ${host}...`);
server.listen({ host: host, port: port }, (err, address) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }
    console.log(`Server started on port ${port}`);
});
// Function to create the admin user
function createAdminUser() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield server.inject({
                method: 'POST',
                url: '/users/register',
                payload: {
                    username: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                    email: process.env.ADMIN_EMAIL,
                }
            });
            console.log('Admin user created or already exists.');
        }
        catch (err) {
            if (err.message.includes('already taken')) {
                console.log('Admin user already exists.');
            }
            else {
                throw err;
            }
        }
    });
}
function clearCollections() {
    return __awaiter(this, void 0, void 0, function* () {
        const collections = yield mongoose.connection.db.collections();
        for (let collection of collections) {
            yield collection.deleteMany({});
        }
        console.log('Collections cleared.');
    });
}
// Export the server for testing
module.exports = server;
