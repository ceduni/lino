import { faker } from '@faker-js/faker';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const Fastify = require('fastify');
const mongoose = require('mongoose');
const path = require('path');
const fastifyJwt = require('@fastify/jwt');
const fastifyCors = require('@fastify/cors');
const bookRoutes = require('../routes/book.route');
const bookboxRoutes = require('../routes/bookbox.route');
const userRoutes = require('../routes/user.route');
const transactionRoutes = require('../routes/transaction.route');
const requestRoutes = require('../routes/request.route');

// Montreal coordinates bounds for generating bookbox locations
const MONTREAL_BOUNDS = {
    north: 45.7041,
    south: 45.4042,
    east: -73.4754,
    west: -73.9738
};

// Common book genres
const BOOK_GENRES = [
    'Fiction', 'Non-Fiction', 'Mystery', 'Romance', 'Science Fiction', 'Fantasy',
    'Biography', 'History', 'Self-Help', 'Cooking', 'Travel', 'Art', 'Poetry',
    'Drama', 'Horror', 'Thriller', 'Adventure', 'Philosophy', 'Religion', 'Health'
];

/**
 * Initialize and configure the Fastify server for testing
 */
async function createTestServer() {
    const server = Fastify({ logger: { level: 'error' } });

    server.register(fastifyCors, {
        origin: true,
    });

    // Register JWT plugin
    server.register(fastifyJwt, { secret: process.env.JWT_SECRET_KEY });

    // Authentication hooks
    server.decorate('authenticate', async (request: any, reply: any) => {
        try {
            await request.jwtVerify();
        } catch (err) {
            reply.send(err);
        }
    });

    server.decorate('bookManipAuth', async (request: any, reply: any) => {
        try {
            const bookManipToken = request.headers['bm_token'];
            const predefinedToken = process.env.BOOK_MANIPULATION_TOKEN || 'not_set';

            if (bookManipToken !== predefinedToken) {
                return reply.status(401).send({ error: 'Unauthorized' });
            }
        } catch (error) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }
    });

    server.decorate('optionalAuthenticate', async (request: any) => {
        try {
            const authHeader = request.headers.authorization;
            if (authHeader) {
                request.user = await server.jwt.verify(authHeader.split(' ')[1]);
            } else {
                request.user = null;
            }
        } catch (error) {
            request.user = null;
        }
    });

    server.decorate('adminAuthenticate', async (request: any, reply: any) => {
        try {
            const authHeader = request.headers.authorization;
            if (!authHeader) {
                return reply.status(401).send({ error: 'Unauthorized' });
            }
            const token = authHeader.split(' ')[1];
            const user = await server.jwt.verify(token) as { username: string };
            if (user.username !== process.env.ADMIN_USERNAME) {
                reply.status(401).send({ error: 'Unauthorized' });
            }
        } catch (error) {
            reply.status(401).send({ error: 'Unauthorized' });
        }
    });

    // Register routes
    server.register(bookRoutes);
    server.register(bookboxRoutes);
    server.register(userRoutes);
    server.register(transactionRoutes);
    server.register(requestRoutes);

    // Connect to MongoDB
    const dbUri = process.env.TEST_MONGODB_URI || process.env.MONGODB_URI || 'mongodb://localhost:27017/lino_test';
    await mongoose.connect(dbUri);

    await server.ready();
    return server;
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
    await server.inject({
        method: 'DELETE',
        url: '/transactions/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    await server.inject({
        method: 'DELETE',
        url: '/users/notifications/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    console.log('Database reinitialized.');
    return token;
}

/**
 * Generate random coordinates within Montreal bounds
 */
function generateMontrealCoordinates(): { latitude: number; longitude: number } {
    const latitude = faker.number.float({
        min: MONTREAL_BOUNDS.south,
        max: MONTREAL_BOUNDS.north,
        fractionDigits: 6
    });
    const longitude = faker.number.float({
        min: MONTREAL_BOUNDS.west,
        max: MONTREAL_BOUNDS.east,
        fractionDigits: 6
    });
    return { latitude, longitude };
}

/**
 * Generate a random book object
 */
function generateRandomBook() {
    const authors = Array.from({ length: faker.number.int({ min: 1, max: 3 }) }, () => 
        faker.person.fullName()
    );
    const categories = faker.helpers.arrayElements(BOOK_GENRES, { min: 1, max: 3 });
    
    return {
        isbn: faker.commerce.isbn(),
        title: faker.helpers.fake('{{lorem.words(2)}}'),
        authors,
        description: faker.lorem.paragraphs(2),
        coverImage: `https://picsum.photos/300/400?random=${faker.number.int({ min: 1, max: 10000 })}`,
        publisher: faker.company.name(),
        categories,
        parutionYear: faker.number.int({ min: 1950, max: 2024 }),
        pages: faker.number.int({ min: 50, max: 800 })
    };
}

/**
 * Generate a book with specific title
 */
function generateBookWithTitle(title: string) {
    const authors = Array.from({ length: faker.number.int({ min: 1, max: 3 }) }, () => 
        faker.person.fullName()
    );
    const categories = faker.helpers.arrayElements(BOOK_GENRES, { min: 1, max: 3 });
    
    return {
        isbn: faker.commerce.isbn(),
        title,
        authors,
        description: faker.lorem.paragraphs(2),
        coverImage: `https://picsum.photos/300/400?random=${faker.number.int({ min: 1, max: 10000 })}`,
        publisher: faker.company.name(),
        categories,
        parutionYear: faker.number.int({ min: 1950, max: 2024 }),
        pages: faker.number.int({ min: 50, max: 800 })
    };
}

/**
 * Create a single user via API
 */
async function createUser(server: any, username: string, email: string): Promise<any> {
    const password = 'password123'; // Default password for test users
    const phone = faker.phone.number();
    const favouriteGenres = faker.helpers.arrayElements(BOOK_GENRES, { min: 1, max: 5 });

    try {
        // Register user
        const registerResponse = await server.inject({
            method: 'POST',
            url: '/users/register',
            payload: {
                username,
                password,
                email,
                phone,
                favouriteGenres,
                requestNotificationRadius: faker.number.int({ min: 1, max: 20 })
            }
        });

        if (registerResponse.statusCode !== 201) {
            console.log(`Failed to create user ${username}:`, registerResponse.json());
            return null;
        }

        // Login to get token
        const loginResponse = await server.inject({
            method: 'POST',
            url: '/users/login',
            payload: {
                identifier: username,
                password
            }
        });

        if (loginResponse.statusCode !== 200) {
            console.log(`Failed to login user ${username}:`, loginResponse.json());
            return null;
        }

        const { token } = loginResponse.json();

        return { username, token, email, phone, favouriteGenres };

    } catch (error) {
        console.log(`Failed to create user ${username}:`, error);
        return null;
    }
}

/**
 * Update user location
 */
async function updateUserLocation(server: any, user: any, coordinates: { latitude: number; longitude: number }): Promise<void> {
    try {
        await server.inject({
            method: 'POST',
            url: '/users/location',
            headers: {
                Authorization: `Bearer ${user.token}`
            },
            payload: {
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            }
        });
    } catch (error) {
        console.log(`Failed to update location for user ${user.username}:`, error);
    }
}

/**
 * Update user notification radius
 */
async function updateUserNotificationRadius(server: any, user: any, radius: number): Promise<void> {
    try {
        await server.inject({
            method: 'POST',
            url: '/users/update',
            headers: {
                Authorization: `Bearer ${user.token}`
            },
            payload: {
                requestNotificationRadius: radius
            }
        });
    } catch (error) {
        console.log(`Failed to update notification radius for user ${user.username}:`, error);
    }
}

/**
 * Create a single bookbox via API
 */
async function createBookbox(server: any, adminToken: string, name: string, coordinates: { latitude: number; longitude: number }): Promise<any> {
    try {
        const response = await server.inject({
            method: 'POST',
            url: '/bookboxes/new',
            headers: {
                Authorization: `Bearer ${adminToken}`
            },
            payload: {
                name,
                image: `https://picsum.photos/400/300?random=${faker.number.int({ min: 1, max: 10000 })}`,
                longitude: coordinates.longitude,
                latitude: coordinates.latitude,
                infoText: faker.lorem.paragraph()
            }
        });

        if (response.statusCode !== 201) {
            console.log(`Failed to create bookbox ${name}:`, response.json());
            return null;
        }

        const bookbox = response.json();
        return bookbox;

    } catch (error) {
        console.log(`Failed to create bookbox ${name}:`, error);
        return null;
    }
}

/**
 * Add a book to a bookbox via API
 */
async function addBookToBookbox(server: any, bookboxId: string, book: any, userToken: string): Promise<boolean> {
    try {
        const response = await server.inject({
            method: 'POST',
            url: `/bookboxes/${bookboxId}/books/add`,
            headers: {
                'bm_token': process.env.BOOK_MANIPULATION_TOKEN || 'not_set',
                'Authorization': `Bearer ${userToken}`
            },
            payload: book
        });

        if (response.statusCode === 201) {
            return true;
        } else {
            console.log(`Failed to add book to bookbox ${bookboxId}:`, response.json());
            return false;
        }

    } catch (error) {
        console.log(`Failed to add book to bookbox ${bookboxId}:`, error);
        return false;
    }
}

/**
 * Create a book request via API
 */
async function createBookRequest(server: any, user: any, bookTitle: string, coordinates: { latitude: number; longitude: number }): Promise<boolean> {
    try {
        const response = await server.inject({
            method: 'POST',
            url: '/books/request',
            headers: {
                Authorization: `Bearer ${user.token}`
            },
            query: {
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            },
            payload: {
                title: bookTitle,
                customMessage: faker.lorem.sentence()
            }
        });

        if (response.statusCode === 201) {
            return true;
        } else {
            console.log(`Failed to create request for ${user.username}:`, response.json());
            return false;
        }

    } catch (error) {
        console.log(`Failed to create request for ${user.username}:`, error);
        return false;
    }
}

/**
 * Main function to populate the test database
 */
export async function populateTestDatabase(): Promise<void> {
    let server: any = null;

    try {
        console.log('Starting database population...');

        // Create and configure server
        server = await createTestServer();
        console.log('✓ Server initialized');

        // Clear existing data and get admin token
        const adminToken = await reinitDatabase(server);
        console.log('✓ Database cleared');

        // Step 1: Create 10 bookboxes in Montreal
        console.log('\n=== STEP 1: Creating 10 bookboxes ===');
        const bookboxes: any[] = [];
        const bookboxCoordinates: { latitude: number; longitude: number }[] = [];
        
        for (let i = 0; i < 10; i++) {
            const coordinates = generateMontrealCoordinates();
            const name = faker.helpers.fake('{{location.streetAddress}} BookBox');
            const bookbox = await createBookbox(server, adminToken, name, coordinates);
            
            if (bookbox) {
                bookboxes.push(bookbox);
                bookboxCoordinates.push(coordinates);
                console.log(`✓ Created bookbox: ${name}`);
            }
        }

        // Step 2: Create 15 users
        console.log('\n=== STEP 2: Creating 15 users ===');
        const users: any[] = [];
        
        for (let i = 0; i < 15; i++) {
            const username = faker.internet.userName();
            const email = faker.internet.email();
            const user = await createUser(server, username, email);
            
            if (user) {
                users.push(user);
                console.log(`✓ Created user: ${username}`);
            }
        }

        // Step 3: Set 10 users to have same coordinates as bookboxes
        console.log('\n=== STEP 3: Setting user locations to match bookboxes ===');
        const usersWithBookboxLocations: any[] = [];
        
        for (let i = 0; i < Math.min(10, users.length, bookboxes.length); i++) {
            const user = users[i];
            const coordinates = bookboxCoordinates[i];
            const bookbox = bookboxes[i];
            
            await updateUserLocation(server, user, coordinates);
            usersWithBookboxLocations.push({ user, bookbox });
            console.log(`✓ ${user.username} -> ${bookbox.bookbox?.name || bookbox.name} (same coordinates)`);
        }

        // Step 4: Have 5 users each add 5 books to different bookboxes
        console.log('\n=== STEP 4: Users adding books to bookboxes ===');
        const bookAdders: any[] = [];
        
        for (let i = 0; i < Math.min(5, users.length); i++) {
            const user = users[i];
            
            // Each user adds one book to each of the 5 bookboxes
            for (let j = 0; j < Math.min(5, bookboxes.length); j++) {
                const bookbox = bookboxes[j];
                const book = generateRandomBook();
                
                const bookboxId = bookbox.bookbox?._id || bookbox._id;
                const bookboxName = bookbox.bookbox?.name || bookbox.name;
                const success = await addBookToBookbox(server, bookboxId, book, user.token);
                if (success) {
                    bookAdders.push({ user, bookbox, book });
                    console.log(`✓ ${user.username} added "${book.title}" to ${bookboxName}`);
                }
            }
        }

        // Step 5: Set 5 users to have 1000km notification radius and create requests
        console.log('\n=== STEP 5: Setting notification radius and creating requests ===');
        const requestUsers: any[] = [];
        const requestTitles: string[] = [];
        
        for (let i = 5; i < Math.min(10, users.length); i++) {
            const user = users[i];
            const coordinates = generateMontrealCoordinates();
            const bookTitle = faker.lorem.words({ min: 2, max: 4 });
            
            // Update notification radius to 100000km
            await updateUserNotificationRadius(server, user, 100000);
            
            // Create book request
            const success = await createBookRequest(server, user, bookTitle, coordinates);
            if (success) {
                requestUsers.push(user);
                requestTitles.push(bookTitle);
                console.log(`✓ ${user.username} (1000km radius) requested "${bookTitle}"`);
            }
        }

        // Step 6: Have 5 other users add books with same titles as requests
        console.log('\n=== STEP 6: Fulfilling requests with matching books ===');
        const fulfillmentUsers: any[] = [];
        
        for (let i = 10; i < Math.min(15, users.length) && i - 10 < requestTitles.length; i++) {
            const user = users[i];
            const requestTitle = requestTitles[i - 10];
            const bookbox = bookboxes[i % bookboxes.length]; // Cycle through bookboxes
            const book = generateBookWithTitle(requestTitle);
            
            const bookboxId = bookbox.bookbox?._id || bookbox._id;
            const bookboxName = bookbox.bookbox?.name || bookbox.name;
            const success = await addBookToBookbox(server, bookboxId, book, user.token);
            if (success) {
                fulfillmentUsers.push({ user, book, bookbox });
                console.log(`✓ ${user.username} added "${book.title}" to ${bookboxName} (fulfilling request)`);
            }
        }

        // Final Summary
        console.log('\n=== FINAL SUMMARY ===');
        console.log(`✓ Created ${bookboxes.length} bookboxes in Montreal`);
        console.log(`✓ Created ${users.length} users`);
        
        console.log('\n📍 Users with bookbox coordinates:');
        usersWithBookboxLocations.forEach(({ user, bookbox }) => {
            const bookboxName = bookbox.bookbox?.name || bookbox.name;
            console.log(`  • ${user.username} -> ${bookboxName}`);
        });
        
        console.log('\n📚 Users who added initial books:');
        bookAdders.forEach(({ user, book, bookbox }) => {
            const bookboxName = bookbox.bookbox?.name || bookbox.name;
            console.log(`  • ${user.username} added "${book.title}" to ${bookboxName}`);
        });
        
        console.log('\n🔔 Users who created requests (1000km radius):');
        requestUsers.forEach((user, index) => {
            console.log(`  • ${user.username} requested "${requestTitles[index]}"`);
        });
        
        console.log('\n✅ Users who fulfilled requests:');
        fulfillmentUsers.forEach(({ user, book, bookbox }) => {
            const bookboxName = bookbox.bookbox?.name || bookbox.name;
            console.log(`  • ${user.username} added "${book.title}" to ${bookboxName}`);
        });

        console.log('\n✓ Database population completed successfully!');

    } catch (error) {
        console.error('Error populating database:', error);
        throw error;
    } finally {
        // Close server and database connections
        if (server) {
            await server.close();
        }
        if (mongoose.connection.readyState !== 0) {
            await mongoose.connection.close();
        }
    }
}

// If this file is run directly, execute the population
if (require.main === module) {
    populateTestDatabase()
        .then(() => {
            console.log('Database population completed');
            process.exit(0);
        })
        .catch((error) => {
            console.error('Database population failed:', error);
            process.exit(1);
        });
}
