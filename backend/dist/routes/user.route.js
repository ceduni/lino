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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = userRoutes;
const user_service_1 = __importDefault(require("../services/user.service"));
const user_model_1 = __importDefault(require("../models/user.model"));
const user_schemas_1 = require("../schemas/user.schemas");
function registerUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield user_service_1.default.registerUser(request.body);
            reply.code(201).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function loginUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield user_service_1.default.loginUser(request.body);
            reply.send({ token: response.token });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function getUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const authRequest = request;
            const userId = authRequest.user.id; // Extract user ID from JWT token
            const user = yield user_model_1.default.findById(userId);
            reply.send({ user: user });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function getUserNotifications(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const notifications = yield user_service_1.default.getUserNotifications(request);
            reply.send({ notifications: notifications });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function readNotification(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const notifications = yield user_service_1.default.readNotification(request);
            reply.code(200).send({ notifications: notifications });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function updateUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield user_service_1.default.updateUser(request);
            reply.send({ user: user });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function clearCollection(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield user_service_1.default.clearCollection();
            reply.send({ message: 'Users cleared' });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(500).send({ error: message });
        }
    });
}
function userRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/users', { preValidation: [server.authenticate], schema: user_schemas_1.getUserSchema }, getUser);
        server.get('/users/notifications', { preValidation: [server.authenticate], schema: user_schemas_1.getUserNotificationsSchema }, getUserNotifications);
        server.post('/users/notifications/read', { preValidation: [server.authenticate], schema: user_schemas_1.readNotificationSchema }, readNotification);
        server.post('/users/register', { schema: user_schemas_1.registerUserSchema }, registerUser);
        server.post('/users/login', { schema: user_schemas_1.loginUserSchema }, loginUser);
        server.post('/users/update', { preValidation: [server.authenticate], schema: user_schemas_1.updateUserSchema }, updateUser);
        server.delete('/users/clear', { preValidation: [server.adminAuthenticate], schema: user_schemas_1.clearCollectionSchema }, clearCollection);
    });
}
