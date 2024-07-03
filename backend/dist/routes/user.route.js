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
const user_service_1 = __importDefault(require("../services/user.service"));
const user_service_2 = __importDefault(require("../services/user.service"));
const user_model_1 = __importDefault(require("../models/user.model"));
function registerUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield user_service_1.default.registerUser(request.body);
            reply.code(201).send(response);
        }
        catch (error) {
            reply.code(400).send({ error: error.message });
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
            reply.code(401).send({ error: 'Invalid credentials' });
        }
    });
}
function addToFavorites(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            // @ts-ignore
            const bookId = request.body.bookId;
            const user = yield user_service_2.default.addToFavorites(userId, bookId);
            if (!user) {
                return;
            }
            reply.code(200).send({ favorites: user.favoriteBooks });
        }
        catch (error) {
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
function removeFromFavorites(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            // @ts-ignore
            const id = request.params.id;
            const user = yield user_service_2.default.removeFromFavorites(userId, id);
            // @ts-ignore
            reply.send({ favorites: user.favoriteBooks });
        }
        catch (error) {
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
function getUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            const user = yield user_model_1.default.findById(userId);
            reply.send({ user: user });
        }
        catch (error) {
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
function getUserFavorites(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            const favorites = yield user_service_2.default.getFavorites(userId);
            reply.send({ favorites: favorites });
        }
        catch (error) {
            reply.code(500).send({ error: 'Internal server error' });
        }
    });
}
function updateUser(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield user_service_2.default.updateUser(request);
            reply.send({ user: user });
        }
        catch (error) {
            reply.code(401).send({ error: error.message });
        }
    });
}
function clearCollection(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        yield user_service_2.default.clearCollection();
        reply.send({ message: 'Users cleared' });
    });
}
function userRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/users', { preValidation: [server.authenticate] }, getUser);
        server.get('/users/favorites', { preValidation: [server.authenticate] }, getUserFavorites);
        server.post('/users/register', registerUser);
        server.post('/users/login', loginUser);
        server.post('/users/update', { preValidation: [server.authenticate] }, updateUser);
        server.post('/users/favorites', { preValidation: [server.authenticate] }, addToFavorites);
        server.delete('/users/favorites/:id', { preValidation: [server.authenticate] }, removeFromFavorites);
        server.delete('/users/clear', { preValidation: [server.adminAuthenticate] }, clearCollection);
    });
}
exports.default = userRoutes;
