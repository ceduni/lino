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
exports.superAdminAuthenticate = exports.adminAuthenticate = exports.optionalAuthenticate = exports.bookManipAuth = exports.authenticate = void 0;
const admin_service_1 = __importDefault(require("../services/admin.service"));
// Authentication hooks
const authenticate = (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield request.jwtVerify();
    }
    catch (err) {
        reply.send(err); // will send an error 401
    }
});
exports.authenticate = authenticate;
// Book manipulation token validation preValidation
const bookManipAuth = (request, reply) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const bookManipToken = request.headers['bm_token']; // Get custom header
        const predefinedToken = process.env.BOOK_MANIPULATION_TOKEN;
        if (bookManipToken !== predefinedToken) {
            console.log('Invalid book manipulation token:', bookManipToken);
            return reply.status(401).send({ error: 'Unauthorized' });
        }
    }
    catch (error) {
        return reply.status(401).send({ error: 'Unauthorized' });
    }
});
exports.bookManipAuth = bookManipAuth;
const optionalAuthenticate = (request, server) => __awaiter(void 0, void 0, void 0, function* () {
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
});
exports.optionalAuthenticate = optionalAuthenticate;
const adminAuthenticate = (request, reply, server) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const authHeader = request.headers.authorization;
        if (!authHeader) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        const token = authHeader.split(' ')[1];
        const user = yield server.jwt.verify(token);
        const isAdmin = yield admin_service_1.default.isAdmin(user.username);
        if (!isAdmin) {
            console.log('Non-admin user tried to access admin route: ', user.username);
            reply.status(401).send({ error: 'Unauthorized' });
        }
        request.user = user; // Attach user info to request
    }
    catch (error) {
        reply.status(401).send({ error: 'Unauthorized' });
    }
});
exports.adminAuthenticate = adminAuthenticate;
const superAdminAuthenticate = (request, reply, server) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const authHeader = request.headers.authorization;
        if (!authHeader) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
        const token = authHeader.split(' ')[1];
        const user = yield server.jwt.verify(token);
        if (user.username !== process.env.ADMIN_USERNAME) {
            console.log('Non-super-admin user tried to access super admin route: ', user.username);
            reply.status(401).send({ error: 'Unauthorized' });
        }
        request.user = user; // Attach user info to request
    }
    catch (error) {
        reply.status(401).send({ error: 'Unauthorized' });
    }
});
exports.superAdminAuthenticate = superAdminAuthenticate;
