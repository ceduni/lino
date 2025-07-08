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
exports.default = serviceRoutes;
const borough_id_generator_1 = require("../services/borough.id.generator");
const services_schemas_1 = require("../schemas/services.schemas");
function getBoroughIdRoute(request, reply) {
    return __awaiter(this, void 0, void 0, function* () {
        const { latitude, longitude } = request.query;
        if (typeof latitude !== 'number' || typeof longitude !== 'number') {
            reply.status(400).send({ error: 'Invalid latitude or longitude' });
            return;
        }
        try {
            const boroughId = yield (0, borough_id_generator_1.getBoroughId)(latitude, longitude);
            reply.send({ boroughId });
        }
        catch (error) {
            console.error('Error generating borough ID:', error);
            reply.status(500).send({ error: 'Internal Server Error' });
        }
    });
}
function serviceRoutes(server) {
    return __awaiter(this, void 0, void 0, function* () {
        server.get('/services/borough-id', { schema: services_schemas_1.boroughIdRouteSchema }, getBoroughIdRoute);
    });
}
