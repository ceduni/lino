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
Object.defineProperty(exports, "__esModule", { value: true });
exports.clients = exports.server = exports.broadcastMessage = exports.broadcastToUser = void 0;
const utilities_1 = require("./services/utilities");
const Fastify = require('fastify');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const fastifyJwt = require('@fastify/jwt');
const fastifyCors = require('@fastify/cors');
const fastifySwagger = require('@fastify/swagger');
const fastifySwaggerUi = require('@fastify/swagger-ui');
const bookRoutes = require('./routes/book.route');
const userRoutes = require('./routes/user.route');
const threadRoutes = require('./routes/thread.route');
const fastifyWebSocket = require('@fastify/websocket');
dotenv.config();
const server = Fastify({ logger: { level: 'error' } });
exports.server = server;
server.register(fastifyCors, {
    origin: true,
});
// Register WebSocket plugin
server.register(fastifyWebSocket);
// Store connected WebSocket clients
const clients = new Set();
exports.clients = clients;
// Function to broadcast a message to a specific user
function broadcastToUser(userId, message) {
    try {
        clients.forEach((client) => {
            // @ts-ignore
            if (client.userId === userId && client.socket.readyState === 1) {
                // @ts-ignore
                client.socket.send(JSON.stringify(message));
            }
        });
    }
    catch (error) {
        console.log('Failed to broadcast message to user:', error.message);
        throw (0, utilities_1.newErr)(500, error.message);
    }
}
exports.broadcastToUser = broadcastToUser;
function broadcastMessage(event, data) {
    try {
        clients.forEach((client) => {
            // @ts-ignore
            if (client.socket.readyState === 1) { // 1 means OPEN
                // @ts-ignore
                client.socket.send(JSON.stringify({ event, data }));
            }
        });
    }
    catch (error) {
        console.log('Failed to broadcast message:', error.message);
        throw (0, utilities_1.newErr)(500, error.message);
    }
}
exports.broadcastMessage = broadcastMessage;
// WebSocket route
// @ts-ignore
server.get('/ws', { websocket: true }, (connection, req) => {
    console.log('Request query userId:', req.request.query.userId);
    try {
        connection.userId = req.query.userId; // Store the user ID in the socket to identify the user
    }
    catch (error) {
        connection.userId = 'anonymous'; // Set a default user ID
    }
    clients.add(connection); // Add the connected client to the set
    connection.socket.on('message', (msg) => {
        console.log('Received message:', msg);
    });
    connection.socket.on('close', () => {
        clients.delete(connection);
    });
});
// Register JWT plugin
server.register(fastifyJwt, { secret: process.env.JWT_SECRET_KEY });
// Authentication hooks
// @ts-ignore
server.decorate('authenticate', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield request.jwtVerify();
    }
    catch (err) {
        reply.send(err); // will send an error 401
    }
}));
// @ts-ignore
server.decorate('optionalAuthenticate', (request) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        request.user = yield server.jwt.verify(request.headers.authorization.split(' ')[1]);
    }
    catch (error) {
        request.user = null;
    }
}));
// @ts-ignore
server.decorate('adminAuthenticate', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const token = request.headers.authorization.split(' ')[1];
        const user = yield server.jwt.verify(token);
        if (user.username !== process.env.ADMIN_USERNAME) {
            reply.status(401).send({ error: 'Unauthorized' });
        }
    }
    catch (error) {
        reply.status(401).send(error);
    }
}));
server.register(fastifySwagger, {
    swagger: {
        info: {
            title: 'Lino API',
            description: 'This is the API documentation for the Lino application',
            version: '1.0.0',
        },
        externalDocs: {
            url: 'https://swagger.io',
            description: 'What\'s Swagger?',
        },
        host: 'lino-1.onrender.com', // the host of your API
        schemes: ['https'], // the protocol your API is available on
        consumes: ['application/json'], // the request content-type
        produces: ['application/json'], // the response content-type
        tags: [
            {
                name: 'books',
                description: 'Operations related to books (e.g. search, add, delete)'
            },
            {
                name: 'bookboxes',
                description: 'Operations related to bookboxes (e.g. visit, add)'
            },
            {
                name: 'users',
                description: 'Operations related to users (e.g. login, register)'
            },
            {
                name: 'threads',
                description: 'Operations related to threads (e.g. create, search)'
            },
            {
                name: 'messages',
                description: 'Operations related to messages (e.g. add, react)'
            }
        ]
    },
});
server.register(fastifySwaggerUi, {
    exposeRoute: true,
    routePrefix: '/docs',
});
// Register routes
server.register(bookRoutes);
server.register(userRoutes);
server.register(threadRoutes);
const start = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB connected...');
        const port = process.env.PORT || 3000;
        const host = process.env.RENDER ? '0.0.0.0' : 'localhost';
        yield server.listen({ host, port });
        console.log(`Server started on port ${port}`);
        yield server.ready();
        server.swagger(); // Ensure swagger is called after server starts
    }
    catch (err) {
        console.error(err);
        process.exit(1);
    }
});
start();
