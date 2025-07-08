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
exports.default = transactionRoutes;
const transaction_service_1 = __importDefault(require("../services/transaction.service"));
const transaction_schemas_1 = require("../schemas/transaction.schemas");
function createCustomTransaction(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const body = request.body;
            const transaction = yield transaction_service_1.default.createCustomTransaction(body);
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
            schema: transaction_schemas_1.createCustomTransactionSchema,
            preValidation: [server.adminAuthenticate]
        }, createCustomTransaction);
    });
}
