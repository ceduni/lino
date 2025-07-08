
class CustomError extends Error {
    public statusCode: number;
    constructor(message : string, statusCode : number   ) {
        super(message);
        this.statusCode = statusCode;
        Error.captureStackTrace(this, this.constructor);
    }
}

export function newErr(statusCode: number, message: string): CustomError {
    return new CustomError(message, statusCode);
}

async function createAdminUser(server: any): Promise<string> {
    try {
        await server.inject({
            method: 'POST',
            url: '/users/register',
            payload: {
                username: process.env.ADMIN_USERNAME,
                password: process.env.ADMIN_PASSWORD,
                email: process.env.ADMIN_EMAIL,
            },
        });
        const response = await server.inject({
            method: 'POST',
            url: '/users/login',
            payload: {
                identifier: process.env.ADMIN_USERNAME,
                password: process.env.ADMIN_PASSWORD,
            },
        });
        return response.json().token;
    } catch (err : unknown) {
        const errorMessage = err instanceof Error ? err.message : 'Unknown error';
        if (errorMessage.includes('already taken')) {
            console.log('Admin user already exists.');
        } else {
            throw err;
        }
        return '';
    }
}

export async function reinitDatabase(server: any): Promise<string> {
    const token = await createAdminUser(server);
    await server.inject({
        method: 'DELETE',
        url: '/users/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    await server.inject({
        method: 'DELETE',
        url: '/books/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    await server.inject({
        method: 'DELETE',
        url: '/threads/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    console.log('Database reinitialized.');
    return token;
}
