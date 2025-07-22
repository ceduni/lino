import { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import AdminService from './admin.service';
import { AuthenticatedRequest, MyFastifyInstance } from '../types/common.types';
import {
    getAllAdminsSchema,
    addAdminSchema,
    removeAdminSchema,
    checkAdminStatusSchema,
    clearAdminsSchema,
    addNewBookboxSchema,
    updateBookBoxSchema,
    deleteBookBoxSchema,
    deactivateBookBoxSchema,
    transferBookBoxOwnershipSchema,
    activateBookBoxSchema,
} from './admin.schemas';
import { info } from 'console';

async function getAllAdmins(request: FastifyRequest, reply: FastifyReply) {
    try {
        const admins = await AdminService.getAllAdmins();
        reply.send({ admins });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function addAdmin(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { username } = request.body as { username: string };
        if (!username) {
            return reply.code(400).send({ error: 'Username is required' });
        }
        
        const admin = await AdminService.addAdmin(username);
        reply.code(201).send({ message: 'Admin added successfully', admin });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function removeAdmin(request: FastifyRequest, reply: FastifyReply) {
    try {
        const { username } = request.body as { username: string };
        if (!username) {
            return reply.code(400).send({ error: 'Username is required' });
        }
        
        const result = await AdminService.removeAdmin(username);
        reply.send(result);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function checkAdminStatus(request: FastifyRequest, reply: FastifyReply) {
    try {
        const authRequest = request as AuthenticatedRequest;
        const username = authRequest.user.username;
        const isAdmin = await AdminService.isAdmin(username);
        reply.send({ username, isAdmin });
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function clearAdmins(request: FastifyRequest, reply: FastifyReply) {
    try {
        const result = await AdminService.clearAdmins();
        reply.send(result);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}



// Bookbox Management Functions
async function addNewBookbox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const owner = (request as AuthenticatedRequest).user.username;
        const { name, image, longitude, latitude, infoText } = request.body as {
            name: string;
            image: string;
            longitude: number;
            latitude: number; 
            infoText?: string;
        };
        const response = await AdminService.addNewBookbox(
            {owner, name, latitude, longitude, image, infoText}
        );
        reply.code(201).send(response);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function updateBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const owner = (request as AuthenticatedRequest).user.username;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        if (!bookboxId) {
            return reply.code(400).send({ error: 'Bookbox ID is required' });
        }
        const { name, image, longitude, latitude, infoText } = request.body as {
            name?: string;
            image?: string;
            longitude?: number;
            latitude?: number;
            infoText?: string;
        };
        const response = await AdminService.updateBookBox(
            {owner, bookboxId, name, image, longitude, latitude, infoText}
        );
        reply.code(200).send(response);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function deleteBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const username = (request as AuthenticatedRequest).user.username;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        if (!bookboxId) {
            return reply.code(400).send({ error: 'Bookbox ID is required' });
        }
        const response = await AdminService.deleteBookBox(username, bookboxId);
        reply.code(200).send(response);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';  
        reply.code(statusCode).send({ error: message });
    }
}

async function activateBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const username = (request as AuthenticatedRequest).user.username;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        if (!bookboxId) {
            return reply.code(400).send({ error: 'Bookbox ID is required' });
        }
        const response = await AdminService.activateBookBox(username, bookboxId);
        reply.code(200).send(response);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function deactivateBookBox(request: FastifyRequest, reply: FastifyReply) {
    try {
        const username = (request as AuthenticatedRequest).user.username;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        if (!bookboxId) {
            return reply.code(400).send({ error: 'Bookbox ID is required' });
        }
        const response = await AdminService.deactivateBookBox(username, bookboxId);
        reply.code(200).send(response);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}

async function transferBookBoxOwnership(request: FastifyRequest, reply: FastifyReply) {
    try {
        const username = (request as AuthenticatedRequest).user.username;
        const bookboxId = (request as { params: { bookboxId: string } }).params.bookboxId;
        const newOwner = (request as { body: { newOwner: string } }).body.newOwner;
        if (!bookboxId) {
            return reply.code(400).send({ error: 'Bookbox ID is required' });
        }
        if (!newOwner) {
            return reply.code(400).send({ error: 'New owner is required' });
        }
        const response = await AdminService.transferBookBoxOwnership(username, bookboxId, newOwner);
        reply.code(200).send(response);
    } catch (error: unknown) {
        const statusCode = (error as any).statusCode || 500;
        const message = error instanceof Error ? error.message : 'Unknown error';
        reply.code(statusCode).send({ error: message });
    }
}


export default async function adminRoutes(server: MyFastifyInstance) {
    // Admin Management Routes
    
    // Get all admins (admin only)
    server.get('/admin/list', { 
        preValidation: [server.adminAuthenticate],
        schema: getAllAdminsSchema
    }, getAllAdmins);

    // Add admin (super admin only)
    server.post('/admin/add', { 
        preValidation: [server.superAdminAuthenticate],
        schema: addAdminSchema
    }, addAdmin);

    // Remove admin (super admin only)
    server.delete('/admin/remove', { 
        preValidation: [server.superAdminAuthenticate],
        schema: removeAdminSchema
    }, removeAdmin);

    // Check admin status (authenticated users only)
    server.get('/admin/status', { 
        preValidation: [server.authenticate],
        schema: checkAdminStatusSchema
    }, checkAdminStatus);

    // Clear all admins (super admin only - for testing)
    server.delete('/admin/clear', { 
        preValidation: [server.superAdminAuthenticate],
        schema: clearAdminsSchema
    }, clearAdmins);

    // Bookbox Management Routes    

    // Create new bookbox (admin only)
    server.post('/admin/bookboxes', { 
        preValidation: [server.adminAuthenticate],
        schema: addNewBookboxSchema
    }, addNewBookbox);

    // Update bookbox (admin only - ownership checked in service)
    server.put('/admin/bookboxes/:bookboxId', { 
        preValidation: [server.adminAuthenticate],
        schema: updateBookBoxSchema
    }, updateBookBox);

    // Delete bookbox (admin only - ownership checked in service)
    server.delete('/admin/bookboxes/:bookboxId', { 
        preValidation: [server.adminAuthenticate],
        schema: deleteBookBoxSchema
    }, deleteBookBox);

    // Activate bookbox (admin only - ownership checked in service)
    server.patch('/admin/bookboxes/:bookboxId/activate', { 
        preValidation: [server.adminAuthenticate],
        schema: activateBookBoxSchema
    }, activateBookBox);


    // Deactivate bookbox (admin only - ownership checked in service)
    server.patch('/admin/bookboxes/:bookboxId/deactivate', { 
        preValidation: [server.adminAuthenticate],
        schema: deactivateBookBoxSchema
    }, deactivateBookBox);
    
    // Transfer bookbox ownership (admin only - ownership checked in service)
    server.patch('/admin/bookboxes/:bookboxId/transfer', { 
        preValidation: [server.adminAuthenticate],
        schema: transferBookBoxOwnershipSchema
    }, transferBookBoxOwnership);
}
