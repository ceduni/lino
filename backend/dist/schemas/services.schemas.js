"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.boroughIdRouteSchema = void 0;
exports.boroughIdRouteSchema = {
    querystring: {
        type: 'object',
        properties: {
            latitude: { type: 'number' },
            longitude: { type: 'number' }
        },
        required: ['latitude', 'longitude']
    },
    response: {
        200: {
            type: 'object',
            properties: {
                boroughId: { type: 'string' }
            }
        },
        400: {
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        },
        500: {
            type: 'object',
            properties: {
                error: { type: 'string' }
            }
        }
    }
};
