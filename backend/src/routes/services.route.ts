import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { getBoroughId } from "../services/borough.id.generator";

async function getBoroughIdRoute(request: FastifyRequest, reply: FastifyReply): Promise<void> {
    const { latitude, longitude } = request.query as { latitude: number; longitude: number };

    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
        reply.status(400).send({ error: 'Invalid latitude or longitude' });
        return;
    }

    try {
        const boroughId = await getBoroughId(latitude, longitude);
        reply.send({ boroughId });
    } catch (error) {
        console.error('Error generating borough ID:', error);
        reply.status(500).send({ error: 'Internal Server Error' });
    }
}

const boroughIdRouteSchema = {
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

interface MyFastifyInstance extends FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => void;
    adminAuthenticate: (request: FastifyRequest, reply: FastifyReply) => void;
}
export default async function serviceRoutes(server: MyFastifyInstance) {
    server.get('/services/borough-id', { schema: boroughIdRouteSchema }, getBoroughIdRoute);
}