const server = require('../index');

async function clearCollections() {
    try {
        await server.inject({
            method: 'DELETE',
            url: '/threads/clear'
        });
        await server.inject({
            method: 'DELETE',
            url: '/books/clear'
        });
        await server.inject({
            method: 'DELETE',
            url: '/user/clear'
        });
        console.log('Collections cleared successfully!');
    } catch (error) {
        console.error('Failed to clear collections:', error.response.data);
    }
}

beforeAll(async () => {
    await clearCollections();
});

describe('Test user registration', () => {
    test('Registering a new user', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/user/register',
            payload: {
                email: 'test@example.com',
                password: 'password',
                username: 'testuser',
                phone: '1234567890'
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('username');
        expect(payload).toHaveProperty('password');
        expect(payload.username).toBe('testuser');
        expect(typeof payload.password).toBe('string');
    });
    test('Registering a user with an existing email', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/user/register',
            payload: {
                email: 'test@example.com',
                password: 'password',
                username: 'testuser2',
                phone: '1234567890'
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Email already taken');
    });
    test('Registering a user with an existing username', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/user/register',
            payload: {
                email: 'test2@example.com',
                password: 'password',
                username: 'testuser',
                phone: '1234567890'
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Username already taken');
    });
});

afterAll(async () => {
    await server.close();
});