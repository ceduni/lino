import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { getBoroughId } from "../services/borough.id.generator";
import { boroughIdRouteSchema } from "./services.schemas";
import { MyFastifyInstance } from "../types";

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

export default async function serviceRoutes(server: MyFastifyInstance) {
    server.get('/services/borough-id', { schema: boroughIdRouteSchema }, getBoroughIdRoute);
}
