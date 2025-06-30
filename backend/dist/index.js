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
exports.clients = exports.server = void 0;
exports.broadcastToUser = broadcastToUser;
exports.broadcastMessage = broadcastMessage;
const utilities_1 = require("./services/utilities");
const Fastify = require('fastify');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const fastifyJwt = require('@fastify/jwt');
const fastifyCors = require('@fastify/cors');
const fastifySwagger = require('@fastify/swagger');
const fastifySwaggerUi = require('@fastify/swagger-ui');
const bookRoutes = require('./routes/book.route');
const bookboxRoutes = require('./routes/bookbox.route');
const userRoutes = require('./routes/user.route');
const threadRoutes = require('./routes/thread.route');
const fastifyWebSocket = require('@fastify/websocket');
dotenv.config({ path: path.join(__dirname, '../.env') });
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
            if (client.userId === userId && client.readyState === 1) {
                client.send(JSON.stringify(message));
                console.log('Sent message to user', userId, message);
            }
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        throw (0, utilities_1.newErr)(500, errorMessage);
    }
}
function broadcastMessage(event, data) {
    try {
        clients.forEach((client) => {
            if (client.readyState === 1) {
                client.send(JSON.stringify({ event, data }));
                console.log(event, data);
            }
        });
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        throw (0, utilities_1.newErr)(500, errorMessage);
    }
}
// WebSocket route
server.register(function (server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/ws', { websocket: true }, (socket, req) => {
            const wsClient = socket;
            try {
                const query = req.query;
                wsClient.userId = query.userId; // Store the user ID in the socket to identify the user
            }
            catch (error) {
                wsClient.userId = 'anonymous'; // Set a default user ID
            }
            clients.add(wsClient); // Add the connected client to the set
            wsClient.on('message', (msg) => {
                console.log('Received message:', msg.toString());
            });
            wsClient.on('close', () => {
                clients.delete(wsClient); // Remove the disconnected client from the set
            });
        });
    });
});
// Register JWT plugin
server.register(fastifyJwt, { secret: process.env.JWT_SECRET_KEY });
// Authentication hooks
server.decorate('authenticate', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield request.jwtVerify();
    }
    catch (err) {
        reply.send(err); // will send an error 401
    }
}));
// Book manipulation token validation preValidation
server.decorate('bookManipAuth', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const bookManipToken = request.headers['bm_token']; // Get custom header
        const predefinedToken = 'LinoCanIAddOrRemoveBooksPlsThanksLmao';
        if (bookManipToken !== predefinedToken) {
            console.log('Invalid book manipulation token:', bookManipToken);
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        console.log('Valid book manipulation token');
    }
    catch (error) {
        return reply.status(401).send({ error: 'Unauthorized' });
    }
}));
server.decorate('optionalAuthenticate', (request) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const authHeader = request.headers.authorization;
        if (authHeader) {
            request.user = yield server.jwt.verify(authHeader.split(' ')[1]);
        }
        else {
            request.user = null;
        }
    }
    catch (error) {
        request.user = null;
    }
}));
server.decorate('adminAuthenticate', (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const authHeader = request.headers.authorization;
        if (!authHeader) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        const token = authHeader.split(' ')[1];
        const user = yield server.jwt.verify(token);
        if (user.username !== process.env.ADMIN_USERNAME) {
            console.log('Non-user tried to access admin route: ', user.username);
            reply.status(401).send({ error: 'Unauthorized' });
        }
    }
    catch (error) {
        reply.status(401).send({ error: 'Unauthorized' });
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
server.register(bookboxRoutes);
server.register(userRoutes);
server.register(threadRoutes);
const start = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Starting server initialization...');
        const dbUri = process.env.NODE_ENV === 'test' ? process.env.TEST_MONGODB_URI : process.env.MONGODB_URI;
        console.log(dbUri);
        yield mongoose.connect(dbUri);
        console.log(`MongoDB connected to ${mongoose.connection.db.databaseName}...`);
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
