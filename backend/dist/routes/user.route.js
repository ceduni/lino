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
exports.default = userRoutes;
const services_1 = require("../services");
const models_1 = require("../models");
const schemas_1 = require("../schemas");
function registerUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { username, email, phone, password } = request.body;
            const response = yield services_1.UserService.registerUser(username, email, password, phone);
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
            const { identifier, password } = request.body;
            const response = yield services_1.UserService.loginUser(identifier, password);
            reply.send(response);
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
            const user = yield models_1.User.findById(userId);
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
            const userId = request.user.id;
            const notifications = yield services_1.UserService.getUserNotifications(userId);
            reply.send({ notifications });
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
            const userId = request.user.id;
            const { notificationId } = request.body;
            const notifications = yield services_1.UserService.readNotification(userId, notificationId);
            reply.code(200).send({ notifications });
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
            const userId = request.user.id;
            const { username, password, email, phone, favouriteGenres } = request.body;
            const user = yield services_1.UserService.updateUser(userId, username, password, email, phone, favouriteGenres);
            reply.send({ user });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function addUserFavLocation(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const userId = request.user.id;
            const { latitude, longitude, name, tag } = request.body;
            const result = yield services_1.UserService.addUserFavLocation(userId, latitude, longitude, name, tag);
            reply.send(result);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function deleteUserFavLocation(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const userId = request.user.id;
            const { name } = request.body;
            yield services_1.UserService.deleteUserFavLocation(userId, name);
            reply.send({ message: 'Location removed from favourites' });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function toggleAcceptedNotificationType(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const userId = request.user.id;
            const { type } = request.body;
            const user = yield services_1.UserService.toggleAcceptedNotificationType(userId, type);
            reply.send({ user });
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
            yield services_1.UserService.clearCollection();
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
        server.get('/users', { preValidation: [server.authenticate], schema: schemas_1.getUserSchema }, getUser);
        server.get('/users/notifications', { preValidation: [server.authenticate], schema: schemas_1.getUserNotificationsSchema }, getUserNotifications);
        server.post('/users/notifications/read', { preValidation: [server.authenticate], schema: schemas_1.readNotificationSchema }, readNotification);
        server.post('/users/register', { schema: schemas_1.registerUserSchema }, registerUser);
        server.post('/users/login', { schema: schemas_1.loginUserSchema }, loginUser);
        server.post('/users/update', { preValidation: [server.authenticate], schema: schemas_1.updateUserSchema }, updateUser);
        server.post('/users/location', { preValidation: [server.authenticate], schema: schemas_1.addUserFavLocationSchema }, addUserFavLocation);
        server.delete('/users/location', { preValidation: [server.authenticate], schema: schemas_1.deleteUserFavLocationSchema }, deleteUserFavLocation);
        server.put('/users/notifications/toggle', { preValidation: [server.authenticate], schema: schemas_1.toggleAcceptedNotificationTypeSchema }, toggleAcceptedNotificationType);
        server.delete('/users/clear', { preValidation: [server.superAdminAuthenticate], schema: schemas_1.clearCollectionSchema }, clearCollection);
        server.delete('/users/notifications/clear', { preValidation: [server.superAdminAuthenticate] }, (request, reply) => __awaiter(this, void 0, void 0, function* () {
            try {
                yield services_1.UserService.clearNotifications();
                reply.send({ message: 'Notifications cleared' });
            }
            catch (error) {
                const statusCode = error.statusCode || 500;
                const message = error instanceof Error ? error.message : 'Unknown error';
                reply.code(statusCode).send({ error: message });
            }
        }));
    });
}
