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
exports.default = transactionRoutes;
const services_1 = require("../services");
function createCustomTransaction(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const { username, action, bookTitle, bookboxId, day, hour } = request.body;
            const transaction = yield services_1.TransactionService.createCustomTransaction(username, action, bookTitle, bookboxId, day, hour);
            reply.code(201).send(transaction);
        }
        catch (error) {
            const statusCode = error.statusCode || 400;
            const message = error instanceof Error ? error.message : 'Unknown error';
            reply.code(statusCode).send({ error: message });
        }
    });
}
function transactionRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.post('/transactions/custom', {
            preValidation: [server.superAdminAuthenticate]
        }, createCustomTransaction);
        server.delete('/transactions/clear', {
            preValidation: [server.superAdminAuthenticate]
        }, (request, reply) => __awaiter(this, void 0, void 0, function* () {
            try {
                yield services_1.TransactionService.clearCollection();
                reply.send({ message: 'Transactions cleared' });
            }
            catch (error) {
                const statusCode = error.statusCode || 500;
                const message = error instanceof Error ? error.message : 'Unknown error';
                reply.code(statusCode).send({ error: message });
            }
        }));
    });
}
