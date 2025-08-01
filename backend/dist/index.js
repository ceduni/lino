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
const utilities_1 = require("./utilities/utilities");
const middlewares_1 = require("./middlewares");
const routes_1 = require("./routes");
const Fastify = require('fastify');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const fastifyJwt = require('@fastify/jwt');
const fastifyCors = require('@fastify/cors');
const fastifySwagger = require('@fastify/swagger');
const fastifySwaggerUi = require('@fastify/swagger-ui');
const fastifyWebSocket = require('@fastify/websocket');
dotenv.config({ path: path.join(__dirname, '../.env') });
const getLogLevel = () => {
    switch (process.env.NODE_ENV) {
        case 'prod': return 'error'; // Deployment
        case 'dev': return 'info'; // Local dev with npm run dev
        case 'test': return 'silent'; // Jest tests
        default: return 'info'; // Fallback
    }
};
const server = Fastify({ logger: { level: getLogLevel() } });
exports.server = server;
server.setErrorHandler((error, request, reply) => {
    // Handle validation errors (schema failures)
    if (error.validation) {
        const validationErrors = error.validation.map((err) => {
            const field = err.instancePath ? err.instancePath.replace('/', '') : err.schemaPath;
            return `${field}: ${err.message}`;
        });
        reply.code(400).send({
            error: 'Validation failed',
            details: validationErrors,
            message: `Invalid request data: ${validationErrors.join(', ')}`
        });
        return;
    }
    // Handle JWT errors
    if (error.code === 'FST_JWT_NO_AUTHORIZATION_IN_HEADER') {
        reply.code(401).send({ error: 'Missing authorization header' });
        return;
    }
    if (error.code === 'FST_JWT_AUTHORIZATION_TOKEN_INVALID') {
        reply.code(401).send({ error: 'Invalid or expired token' });
        return;
    }
    // Handle other known error codes
    const statusCode = error.statusCode || 500;
    const message = error instanceof Error ? error.message : 'Internal server error';
    // Log server errors but not client errors
    if (statusCode >= 500) {
        console.error('Server Error:', error);
    }
    reply.code(statusCode).send({ error: message });
});
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
// Register authentication middleware as decorators
server.decorate('authenticate', middlewares_1.authenticate);
server.decorate('bookManipAuth', middlewares_1.bookManipAuth);
server.decorate('optionalAuthenticate', (request) => (0, middlewares_1.optionalAuthenticate)(request, server));
server.decorate('adminAuthenticate', (request, reply) => (0, middlewares_1.adminAuthenticate)(request, reply, server));
server.decorate('superAdminAuthenticate', (request, reply) => (0, middlewares_1.superAdminAuthenticate)(request, reply, server));
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
            },
            {
                name: 'transactions',
                description: 'Operations related to transactions (e.g. create custom transaction)'
            },
            {
                name: 'admin',
                description: 'Admin-only operations'
            }
        ]
    },
});
server.register(fastifySwaggerUi, {
    exposeRoute: true,
    routePrefix: '/docs',
});
// Register routes
server.register(routes_1.bookRoutes);
server.register(routes_1.bookboxRoutes);
server.register(routes_1.requestRoutes);
server.register(routes_1.userRoutes);
// server.register(threadRoutes); // Uncomment if you want to enable thread routes
server.register(routes_1.transactionRoutes);
server.register(routes_1.serviceRoutes);
server.register(routes_1.adminRoutes);
server.register(routes_1.searchRoutes);
server.register(routes_1.issueRoutes);
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
