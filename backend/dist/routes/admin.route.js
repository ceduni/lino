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
exports.default = adminRoutes;
const services_1 = require("../services");
const schemas_1 = require("../schemas");
function searchAdmins(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { q, limit = 20, page = 1 } = request.query;
            const username = request.user.username;
            const results = yield services_1.AdminService.searchAdmins(username, q, limit, page);
            reply.send(results);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function addAdmin(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { username } = request.body;
            if (!username) {
                return reply.code(400).send({ error: 'Username is required' });
            }
            const admin = yield services_1.AdminService.addAdmin(username);
            reply.code(201).send({ message: 'Admin added successfully', admin });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function removeAdmin(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { username } = request.body;
            if (!username) {
                return reply.code(400).send({ error: 'Username is required' });
            }
            const result = yield services_1.AdminService.removeAdmin(username);
            reply.send(result);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function checkAdminStatus(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const authRequest = request;
            const username = authRequest.user.username;
            const isAdmin = yield services_1.AdminService.isAdmin(username);
            reply.send({ username, isAdmin });
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function clearAdmins(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const result = yield services_1.AdminService.clearAdmins();
            reply.send(result);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
// Bookbox Management Functions
function addNewBookbox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const owner = request.user.username;
            const { name, image, longitude, latitude, infoText } = request.body;
            const response = yield services_1.AdminService.addNewBookbox({ owner, name, latitude, longitude, image, infoText });
            reply.code(201).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function updateBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const owner = request.user.username;
            const bookboxId = request.params.bookboxId;
            if (!bookboxId) {
                return reply.code(400).send({ error: 'Bookbox ID is required' });
            }
            const { name, image, longitude, latitude, infoText } = request.body;
            const response = yield services_1.AdminService.updateBookBox({ owner, bookboxId, name, image, longitude, latitude, infoText });
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function deleteBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const username = request.user.username;
            const bookboxId = request.params.bookboxId;
            if (!bookboxId) {
                return reply.code(400).send({ error: 'Bookbox ID is required' });
            }
            const response = yield services_1.AdminService.deleteBookBox(username, bookboxId);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function activateBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const username = request.user.username;
            const bookboxId = request.params.bookboxId;
            if (!bookboxId) {
                return reply.code(400).send({ error: 'Bookbox ID is required' });
            }
            const response = yield services_1.AdminService.activateBookBox(username, bookboxId);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function deactivateBookBox(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const username = request.user.username;
            const bookboxId = request.params.bookboxId;
            if (!bookboxId) {
                return reply.code(400).send({ error: 'Bookbox ID is required' });
            }
            const response = yield services_1.AdminService.deactivateBookBox(username, bookboxId);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function transferBookBoxOwnership(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const username = request.user.username;
            const bookboxId = request.params.bookboxId;
            const newOwner = request.body.newOwner;
            if (!bookboxId) {
                return reply.code(400).send({ error: 'Bookbox ID is required' });
            }
            if (!newOwner) {
                return reply.code(400).send({ error: 'New owner is required' });
            }
            const response = yield services_1.AdminService.transferBookBoxOwnership(username, bookboxId, newOwner);
            reply.code(200).send(response);
        }
        catch (error) {
            const statusCode = error.statusCode || 500;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function adminRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        // Admin Management Routes
        // Search admins (admin only)
        server.get('/search/admins', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.searchAdminsSchema
        }, searchAdmins);
        // Add admin (super admin only)
        server.post('/admin/add', {
            preValidation: [server.superAdminAuthenticate],
            schema: schemas_1.addAdminSchema
        }, addAdmin);
        // Remove admin (super admin only)
        server.delete('/admin/remove', {
            preValidation: [server.superAdminAuthenticate],
            schema: schemas_1.removeAdminSchema
        }, removeAdmin);
        // Check admin status (authenticated users only)
        server.get('/admin/status', {
            preValidation: [server.authenticate],
            schema: schemas_1.checkAdminStatusSchema
        }, checkAdminStatus);
        // Clear all admins (super admin only - for testing)
        server.delete('/admin/clear', {
            preValidation: [server.superAdminAuthenticate],
            schema: schemas_1.clearAdminsSchema
        }, clearAdmins);
        // Bookbox Management Routes    
        // Create new bookbox (admin only)
        server.post('/admin/bookboxes', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.addNewBookboxSchema
        }, addNewBookbox);
        // Update bookbox (admin only - ownership checked in service)
        server.put('/admin/bookboxes/:bookboxId', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.updateBookBoxSchema
        }, updateBookBox);
        // Delete bookbox (admin only - ownership checked in service)
        server.delete('/admin/bookboxes/:bookboxId', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.deleteBookBoxSchema
        }, deleteBookBox);
        // Activate bookbox (admin only - ownership checked in service)
        server.patch('/admin/bookboxes/:bookboxId/activate', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.activateBookBoxSchema
        }, activateBookBox);
        // Deactivate bookbox (admin only - ownership checked in service)
        server.patch('/admin/bookboxes/:bookboxId/deactivate', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.deactivateBookBoxSchema
        }, deactivateBookBox);
        // Transfer bookbox ownership (admin only - ownership checked in service)
        server.patch('/admin/bookboxes/:bookboxId/transfer', {
            preValidation: [server.adminAuthenticate],
            schema: schemas_1.transferBookBoxOwnershipSchema
        }, transferBookBoxOwnership);
    });
}
