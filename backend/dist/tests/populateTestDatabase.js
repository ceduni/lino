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
exports.reinitDatabase = reinitDatabase;
exports.populateTestDatabase = populateTestDatabase;
const faker_1 = require("@faker-js/faker");
const dotenv_1 = __importDefault(require("dotenv"));
// Load environment variables
dotenv_1.default.config();
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
function createTestServer() {
    return __awaiter(this, void 0, void 0, function* () {
        const server = Fastify({ logger: { level: 'error' } });
        server.register(fastifyCors, {
            origin: true,
        });
        // Register JWT plugin
        server.register(fastifyJwt, { secret: process.env.JWT_SECRET_KEY });
        // Authentication hooks
        server.decorate('authenticate', (request, reply) => __awaiter(this, void 0, void 0, function* () {
            try {
                yield request.jwtVerify();
            }
            catch (err) {
                reply.send(err);
            }
        }));
        server.decorate('bookManipAuth', (request, reply) => __awaiter(this, void 0, void 0, function* () {
            try {
                const bookManipToken = request.headers['bm_token'];
                const predefinedToken = process.env.BOOK_MANIPULATION_TOKEN || 'not_set';
                if (bookManipToken !== predefinedToken) {
                    return reply.status(401).send({ error: 'Unauthorized' });
                }
            }
            catch (error) {
                return reply.status(401).send({ error: 'Unauthorized' });
            }
        }));
        server.decorate('optionalAuthenticate', (request) => __awaiter(this, void 0, void 0, function* () {
            try {
                const authHeader = request.headers.authorization;
                if (authHeader) {
                    request.user = yield server.jwt.verify(authHeader.split(' ')[1]);
                }
                else {
                    request.user = null;
                }
            }
            catch (error) {
                request.user = null;
            }
        }));
        server.decorate('adminAuthenticate', (request, reply) => __awaiter(this, void 0, void 0, function* () {
            try {
                const authHeader = request.headers.authorization;
                if (!authHeader) {
                    return reply.status(401).send({ error: 'Unauthorized' });
                }
                const token = authHeader.split(' ')[1];
                const user = yield server.jwt.verify(token);
                if (user.username !== process.env.ADMIN_USERNAME) {
                    reply.status(401).send({ error: 'Unauthorized' });
                }
            }
            catch (error) {
                reply.status(401).send({ error: 'Unauthorized' });
            }
        }));
        // Register routes
        server.register(bookRoutes);
        server.register(bookboxRoutes);
        server.register(userRoutes);
        server.register(transactionRoutes);
        server.register(requestRoutes);
        // Connect to MongoDB
        const dbUri = process.env.TEST_MONGODB_URI || process.env.MONGODB_URI || 'mongodb://localhost:27017/lino_test';
        yield mongoose.connect(dbUri);
        yield server.ready();
        return server;
    });
}
function createAdminUser(server) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield server.inject({
                method: 'POST',
                url: '/users/register',
                payload: {
                    username: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                    email: process.env.ADMIN_EMAIL,
                },
            });
            const response = yield server.inject({
                method: 'POST',
                url: '/users/login',
                payload: {
                    identifier: process.env.ADMIN_USERNAME,
                    password: process.env.ADMIN_PASSWORD,
                },
            });
            return response.json().token;
        }
        catch (err) {
            const errorMessage = err instanceof Error ? err.message : 'Unknown error';
            if (errorMessage.includes('already taken')) {
                console.log('Admin user already exists.');
            }
            else {
                throw err;
            }
            return '';
        }
    });
}
function reinitDatabase(server) {
    return __awaiter(this, void 0, void 0, function* () {
        const token = yield createAdminUser(server);
        yield server.inject({
            method: 'DELETE',
            url: '/users/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/books/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/threads/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/transactions/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        yield server.inject({
            method: 'DELETE',
            url: '/users/notifications/clear',
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });
        console.log('Database reinitialized.');
        return token;
    });
}
/**
 * Generate random coordinates within Montreal bounds
 */
function generateMontrealCoordinates() {
    const latitude = faker_1.faker.number.float({
        min: MONTREAL_BOUNDS.south,
        max: MONTREAL_BOUNDS.north,
        fractionDigits: 6
    });
    const longitude = faker_1.faker.number.float({
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
    const authors = Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => faker_1.faker.person.fullName());
    const categories = faker_1.faker.helpers.arrayElements(BOOK_GENRES, { min: 1, max: 3 });
    return {
        isbn: faker_1.faker.commerce.isbn(),
        title: faker_1.faker.helpers.fake('{{lorem.words(2)}}'),
        authors,
        description: faker_1.faker.lorem.paragraphs(2),
        coverImage: `https://picsum.photos/300/400?random=${faker_1.faker.number.int({ min: 1, max: 10000 })}`,
        publisher: faker_1.faker.company.name(),
        categories,
        parutionYear: faker_1.faker.number.int({ min: 1950, max: 2024 }),
        pages: faker_1.faker.number.int({ min: 50, max: 800 })
    };
}
/**
 * Generate a book with specific title
 */
function generateBookWithTitle(title) {
    const authors = Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => faker_1.faker.person.fullName());
    const categories = faker_1.faker.helpers.arrayElements(BOOK_GENRES, { min: 1, max: 3 });
    return {
        isbn: faker_1.faker.commerce.isbn(),
        title,
        authors,
        description: faker_1.faker.lorem.paragraphs(2),
        coverImage: `https://picsum.photos/300/400?random=${faker_1.faker.number.int({ min: 1, max: 10000 })}`,
        publisher: faker_1.faker.company.name(),
        categories,
        parutionYear: faker_1.faker.number.int({ min: 1950, max: 2024 }),
        pages: faker_1.faker.number.int({ min: 50, max: 800 })
    };
}
/**
 * Create a single user via API
 */
function createUser(server, username, email) {
    return __awaiter(this, void 0, void 0, function* () {
        const password = 'password123'; // Default password for test users
        const phone = faker_1.faker.phone.number();
        const favouriteGenres = faker_1.faker.helpers.arrayElements(BOOK_GENRES, { min: 1, max: 5 });
        try {
            // Register user
            const registerResponse = yield server.inject({
                method: 'POST',
                url: '/users/register',
                payload: {
                    username,
                    password,
                    email,
                    phone,
                    favouriteGenres,
                    requestNotificationRadius: faker_1.faker.number.int({ min: 1, max: 20 })
                }
            });
            if (registerResponse.statusCode !== 201) {
                console.log(`Failed to create user ${username}:`, registerResponse.json());
                return null;
            }
            // Login to get token
            const loginResponse = yield server.inject({
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
        }
        catch (error) {
            console.log(`Failed to create user ${username}:`, error);
            return null;
        }
    });
}
/**
 * Update user location
 */
function updateUserLocation(server, user, coordinates) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield server.inject({
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
        }
        catch (error) {
            console.log(`Failed to update location for user ${user.username}:`, error);
        }
    });
}
/**
 * Update user notification radius
 */
function updateUserNotificationRadius(server, user, radius) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield server.inject({
                method: 'POST',
                url: '/users/update',
                headers: {
                    Authorization: `Bearer ${user.token}`
                },
                payload: {
                    requestNotificationRadius: radius
                }
            });
        }
        catch (error) {
            console.log(`Failed to update notification radius for user ${user.username}:`, error);
        }
    });
}
/**
 * Create a single bookbox via API
 */
function createBookbox(server, adminToken, name, coordinates) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield server.inject({
                method: 'POST',
                url: '/bookboxes/new',
                headers: {
                    Authorization: `Bearer ${adminToken}`
                },
                payload: {
                    name,
                    image: `https://picsum.photos/400/300?random=${faker_1.faker.number.int({ min: 1, max: 10000 })}`,
                    longitude: coordinates.longitude,
                    latitude: coordinates.latitude,
                    infoText: faker_1.faker.lorem.paragraph()
                }
            });
            if (response.statusCode !== 201) {
                console.log(`Failed to create bookbox ${name}:`, response.json());
                return null;
            }
            const bookbox = response.json();
            return bookbox;
        }
        catch (error) {
            console.log(`Failed to create bookbox ${name}:`, error);
            return null;
        }
    });
}
/**
 * Add a book to a bookbox via API
 */
function addBookToBookbox(server, bookboxId, book, userToken) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield server.inject({
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
            }
            else {
                console.log(`Failed to add book to bookbox ${bookboxId}:`, response.json());
                return false;
            }
        }
        catch (error) {
            console.log(`Failed to add book to bookbox ${bookboxId}:`, error);
            return false;
        }
    });
}
/**
 * Create a book request via API
 */
function createBookRequest(server, user, bookTitle, coordinates) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const response = yield server.inject({
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
                    customMessage: faker_1.faker.lorem.sentence()
                }
            });
            if (response.statusCode === 201) {
                return true;
            }
            else {
                console.log(`Failed to create request for ${user.username}:`, response.json());
                return false;
            }
        }
        catch (error) {
            console.log(`Failed to create request for ${user.username}:`, error);
            return false;
        }
    });
}
/**
 * Main function to populate the test database
 */
function populateTestDatabase() {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b, _c, _d, _e;
        let server = null;
        try {
            console.log('Starting database population...');
            // Create and configure server
            server = yield createTestServer();
            console.log('✓ Server initialized');
            // Clear existing data and get admin token
            const adminToken = yield reinitDatabase(server);
            console.log('✓ Database cleared');
            // Step 1: Create 10 bookboxes in Montreal
            console.log('\n=== STEP 1: Creating 10 bookboxes ===');
            const bookboxes = [];
            const bookboxCoordinates = [];
            for (let i = 0; i < 10; i++) {
                const coordinates = generateMontrealCoordinates();
                const name = faker_1.faker.helpers.fake('{{location.streetAddress}} BookBox');
                const bookbox = yield createBookbox(server, adminToken, name, coordinates);
                if (bookbox) {
                    bookboxes.push(bookbox);
                    bookboxCoordinates.push(coordinates);
                    console.log(`✓ Created bookbox: ${name}`);
                }
            }
            // Step 2: Create 15 users
            console.log('\n=== STEP 2: Creating 15 users ===');
            const users = [];
            for (let i = 0; i < 15; i++) {
                const username = faker_1.faker.internet.userName();
                const email = faker_1.faker.internet.email();
                const user = yield createUser(server, username, email);
                if (user) {
                    users.push(user);
                    console.log(`✓ Created user: ${username}`);
                }
            }
            // Step 3: Set 10 users to have same coordinates as bookboxes
            console.log('\n=== STEP 3: Setting user locations to match bookboxes ===');
            const usersWithBookboxLocations = [];
            for (let i = 0; i < Math.min(10, users.length, bookboxes.length); i++) {
                const user = users[i];
                const coordinates = bookboxCoordinates[i];
                const bookbox = bookboxes[i];
                yield updateUserLocation(server, user, coordinates);
                usersWithBookboxLocations.push({ user, bookbox });
                console.log(`✓ ${user.username} -> ${((_a = bookbox.bookbox) === null || _a === void 0 ? void 0 : _a.name) || bookbox.name} (same coordinates)`);
            }
            // Step 4: Have 5 users each add 5 books to different bookboxes
            console.log('\n=== STEP 4: Users adding books to bookboxes ===');
            const bookAdders = [];
            for (let i = 0; i < Math.min(5, users.length); i++) {
                const user = users[i];
                // Each user adds one book to each of the 5 bookboxes
                for (let j = 0; j < Math.min(5, bookboxes.length); j++) {
                    const bookbox = bookboxes[j];
                    const book = generateRandomBook();
                    const bookboxId = ((_b = bookbox.bookbox) === null || _b === void 0 ? void 0 : _b._id) || bookbox._id;
                    const bookboxName = ((_c = bookbox.bookbox) === null || _c === void 0 ? void 0 : _c.name) || bookbox.name;
                    const success = yield addBookToBookbox(server, bookboxId, book, user.token);
                    if (success) {
                        bookAdders.push({ user, bookbox, book });
                        console.log(`✓ ${user.username} added "${book.title}" to ${bookboxName}`);
                    }
                }
            }
            // Step 5: Set 5 users to have 1000km notification radius and create requests
            console.log('\n=== STEP 5: Setting notification radius and creating requests ===');
            const requestUsers = [];
            const requestTitles = [];
            for (let i = 5; i < Math.min(10, users.length); i++) {
                const user = users[i];
                const coordinates = generateMontrealCoordinates();
                const bookTitle = faker_1.faker.lorem.words({ min: 2, max: 4 });
                // Update notification radius to 100000km
                yield updateUserNotificationRadius(server, user, 100000);
                // Create book request
                const success = yield createBookRequest(server, user, bookTitle, coordinates);
                if (success) {
                    requestUsers.push(user);
                    requestTitles.push(bookTitle);
                    console.log(`✓ ${user.username} (1000km radius) requested "${bookTitle}"`);
                }
            }
            // Step 6: Have 5 other users add books with same titles as requests
            console.log('\n=== STEP 6: Fulfilling requests with matching books ===');
            const fulfillmentUsers = [];
            for (let i = 10; i < Math.min(15, users.length) && i - 10 < requestTitles.length; i++) {
                const user = users[i];
                const requestTitle = requestTitles[i - 10];
                const bookbox = bookboxes[i % bookboxes.length]; // Cycle through bookboxes
                const book = generateBookWithTitle(requestTitle);
                const bookboxId = ((_d = bookbox.bookbox) === null || _d === void 0 ? void 0 : _d._id) || bookbox._id;
                const bookboxName = ((_e = bookbox.bookbox) === null || _e === void 0 ? void 0 : _e.name) || bookbox.name;
                const success = yield addBookToBookbox(server, bookboxId, book, user.token);
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
                var _a;
                const bookboxName = ((_a = bookbox.bookbox) === null || _a === void 0 ? void 0 : _a.name) || bookbox.name;
                console.log(`  • ${user.username} -> ${bookboxName}`);
            });
            console.log('\n📚 Users who added initial books:');
            bookAdders.forEach(({ user, book, bookbox }) => {
                var _a;
                const bookboxName = ((_a = bookbox.bookbox) === null || _a === void 0 ? void 0 : _a.name) || bookbox.name;
                console.log(`  • ${user.username} added "${book.title}" to ${bookboxName}`);
            });
            console.log('\n🔔 Users who created requests (1000km radius):');
            requestUsers.forEach((user, index) => {
                console.log(`  • ${user.username} requested "${requestTitles[index]}"`);
            });
            console.log('\n✅ Users who fulfilled requests:');
            fulfillmentUsers.forEach(({ user, book, bookbox }) => {
                var _a;
                const bookboxName = ((_a = bookbox.bookbox) === null || _a === void 0 ? void 0 : _a.name) || bookbox.name;
                console.log(`  • ${user.username} added "${book.title}" to ${bookboxName}`);
            });
            console.log('\n✓ Database population completed successfully!');
        }
        catch (error) {
            console.error('Error populating database:', error);
            throw error;
        }
        finally {
            // Close server and database connections
            if (server) {
                yield server.close();
            }
            if (mongoose.connection.readyState !== 0) {
                yield mongoose.connection.close();
            }
        }
    });
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
