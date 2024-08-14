const {server} = require('../index');
const { reinitDatabase } = require('../services/utilities');
const {randomInt} = require("node:crypto");

let bbids = [];
let portedBookId;
let portedThreadId;
let portedMessageId;
let token;
let portedBookIds = [];
let fakeQRCodeCounter = 0;

jest.setTimeout(10000);

beforeAll(async () => {
    token = await reinitDatabase(server);

    for (let i = 0; i < 3; i++) {
        const response = await server.inject({
            method: 'POST',
            url: '/bookboxes/new',
            payload: {
                name: `Box${i+1}`,
                infoText: 'Find it yourself',
                latitude: randomInt(-180, 180) + Math.random(),
                longitude: randomInt(-180, 180) + Math.random(),
                image: 'https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png'
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        bbids.push(payload._id);
    }
},);

describe('Test user registration', () => {

    test('Registering a new user', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/users/register',
            payload: {
                email: 'test@example.com',
                password: 'password',
                username: 'testuser',
                phone: '1234567890',
                getAlerted: true
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('username');
        expect(payload).toHaveProperty('password');
        expect(payload.username).toBe('testuser');
        expect(typeof payload.password).toBe('string');
    });

    test('Registering another user', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/users/register',
            payload: {
                email: 'test2@example.com',
                password: 'password',
                username: 'testuser2',
                phone: '1234567890',
                getAlerted: true
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('username');
        expect(payload).toHaveProperty('password');
        expect(payload.username).toBe('testuser2');
        expect(typeof payload.password).toBe('string');
    });

    test('Registering a user with an existing email', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/users/register',
            payload: {
                email: 'test@example.com',
                password: 'password',
                username: 'testuser3',
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
            url: '/users/register',
            payload: {
                email: 'test3@example.com',
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


describe('Test user login and user specific operations', () => {

    test('Logging in with incorrect credentials', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/users/login',
            payload: {
                identifier: 'testuser',
                password: 'password2'
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Invalid password');
    });

    test('Logging in with correct credentials', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/users/login',
            payload: {
                identifier: 'testuser',
                password: 'password'
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('token');
        token = payload.token;
    });

    test('Update user with some keywords', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/users/update',
            payload: {
                keyWords: "Victor Dixen"
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('user');
    });
});


describe('Test book adding by guest users', () => {

    test('Adding a new book', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/books/add',
            headers: {
                Authorization: `Bearer ptdrinexistent`,
                'Content-Type': 'application/json; charset=UTF-8',
            },
            payload: {
                bookboxId: bbids[0],
                qrCodeId: `b${fakeQRCodeCounter++}`,
                isbn: "9782075023986",
                title: "Le cas Jack Spark (Saison 2) - Automne traqué",
                authors: ["Victor Dixen"],
                description: "L'automne est la saison des grandes chasses. La traque est lancée! Grand prix de l'Imaginaire 2010 Étonnants Voyageurs. '\"Le cas Jack Spark\" est une immersion dans la tête d'un adolescent qui réalise être radicalement différent des autres. C'est l'histoire d'un choix, d'un combat, d'un destin extrordinaire' (Victor Dixen).",
                coverImage: "http://books.google.com/books/content?id=t-ZGCgAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                publisher: "Gallimard Jeunesse",
                parutionYear: 2015,
                pages: 369,
                categories: ["Young Adult Fiction"]
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('bookId');
        expect(typeof payload.bookId).toBe('string');
        portedBookId = payload.bookId;
        expect(payload).toHaveProperty('books');
        expect(payload.books[0]).toBe(portedBookId);
        // expect that the users with corresponding keywords get notified about the book
        const user = await getUser(token);
        const userNotifs = user.notifications;
        expect(userNotifs[userNotifs.length-1].content).toBe('The book "Le cas Jack Spark (Saison 2) - Automne traqué" has been added to the bookbox "Box1" !');
    });

    test('Adding a book without a QR code', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/books/add',
            payload: {
                bookboxId: '',
                qrCodeId: '',
                title: "Harry Potter à l'école des sorciers",
                authors: ["J. K. Rowling"],
                publisher: "Gallimard Jeunesse",
                parutionYear: 2013,
                pages: 412,
                categories: ["Thriller"]
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Book\'s QR code ID is required');
    });

    test('Adding a book in an invalid bookBox', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/books/add',
            payload: { // No title
                bookboxId: "6660ec640a7261a8b1131165",
                qrCodeId: `b${fakeQRCodeCounter++}`,
                isbn: "9782075023986",
                title: "Le cas Jack Spark (Saison 2) - Automne traqué",
                authors: ["Victor Dixen"],
                description: "L'automne est la saison des grandes chasses. La traque est lancée! Grand prix de l'Imaginaire 2010 Étonnants Voyageurs. '\"Le cas Jack Spark\" est une immersion dans la tête d'un adolescent qui réalise être radicalement différent des autres. C'est l'histoire d'un choix, d'un combat, d'un destin extrordinaire' (Victor Dixen).",
                coverImage: "http://books.google.com/books/content?id=t-ZGCgAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api",
                publisher: "Gallimard Jeunesse",
                parutionYear: 2015,
                pages: 369,
                categories: ["Young Adult Fiction"]
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(404);
        expect(payload.error).toBe('Bookbox not found');
        fakeQRCodeCounter--;
    });
});


describe('Test book fetching by guest users', () => {

    test('Getting a book from a book box', async () => {
        const response = await server.inject({
            method: 'GET',
            url: `/books/b0/${bbids[0]}` // book with qrCodeId b0 in bookbox with id bbids[0]
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('book');
        expect(payload.book.authors[0]).toBe('Victor Dixen');
        expect(payload).toHaveProperty('books');
        expect(payload.books).toHaveLength(0);
    });

    test('Trying to get the same book from the same book box', async () => {
        const response = await server.inject({
            method: 'GET',
            url: `/books/b0/${bbids[0]}`
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(404);
        expect(payload.error).toBe('Book not found in bookbox');
    });

    test('Adding an already registered book in another book box', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/books/add`,
            payload : {
                bookboxId: bbids[1],
                qrCodeId: `b0`,
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('bookId');
        expect(payload.bookId).toBe(portedBookId);
        expect(payload.books[0]).toBe(portedBookId);
    });

    test('Adding a book registered in a book box in another book box', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/books/add`,
            payload : {
                bookboxId : bbids[2],
                qrCodeId: 'b0',
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Book is supposed to be in the book box Box2');
    });
});


describe('Test book actions by connected users', () => {

    test('Send an alert to users', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/books/request',
            headers: {
                Authorization: `Bearer ${token}`
            },
            payload: {
                title: 'Harry Potter à l\'école des sorciers',
            }
        });
        expect(response.statusCode).toBe(201);
        const token2 = await server.inject({
           method: 'POST',
              url: '/users/login',
                payload: {
                    identifier: 'testuser2',
                    password: 'password'
                }
        });
        const user2 = await getUser(JSON.parse(token2.payload).token);
        expect(user2.notifications[user2.notifications.length-1].content)
            .toBe('The user testuser wants to get the book "Harry Potter à l\'école des sorciers" ! If you have it, please feel free to add it to one of our book boxes !');

    });

    test('Adding a new book', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/books/add',
            payload: {
                bookboxId : bbids[0],
                qrCodeId: `b${fakeQRCodeCounter++}`,
                isbn: "9781781101032",
                title: "Harry Potter à L'école des Sorciers",
                authors: ["J.K. Rowling"],
                description: "Le jour de ses onze ans, Harry Potter, un orphelin élevé par un oncle et une tante qui le détestent, voit son existence bouleversée. Un géant vient le chercher pour l’emmener à Poudlard, une école de sorcellerie! Voler en balai, jeter des sorts, combattre les trolls : Harry Potter se révèle un sorcier doué. Mais un mystère entoure sa naissance et l’effroyable V..., le mage dont personne n’ose prononcer le nom. Amitié, surprises, dangers, scènes comiques, Harry découvre ses pouvoirs et la vie à Poudlard. Le premier tome des aventures du jeune héros vous ensorcelle aussitôt!",
                coverImage: "http://books.google.com/books/content?id=nvijsUyJYR4C&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api",
                publisher: "Pottermore Publishing",
                parutionYear: 2015,
                pages: 357,
                categories: ["Juvenile Fiction"]
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload); // new book adding has already been tested
        console.log(payload);
        portedBookId = payload.bookId;
        // check if the user's ecological impact has been updated
        const user = await getUser(token);
        const ecoImpact = user.ecologicalImpact;
        expect(ecoImpact.carbonSavings).toBe(27.71);
        expect(ecoImpact.savedWater).toBe(2000);
        expect(ecoImpact.savedTrees).toBe(0.005);
    });

    test('Adding a book to the user\'s favorites', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/users/favorites`,
            payload: {
                bookId: portedBookId
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('favorites');
        expect(payload.favorites[0]).toBe(portedBookId);
    });

    test('A guest getting the same book from the book box', async () => {
        const response = await server.inject({
            method: 'GET',
            url: `/books/b1/${bbids[0]}`
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('book');
        expect(payload.book.authors[0]).toBe('J.K. Rowling');
        expect(payload).toHaveProperty('books');
        expect(payload.books).toHaveLength(0);
        // check the book's given history and taken history
        const user = await getUser(token);
        expect(payload.book.givenHistory[0].username).toBe(user.username);
        expect(payload.book.takenHistory[0].username).toBe('guest');
        expect(user.notifications[user.notifications.length-1].content)
            .toBe('The book "Harry Potter à L\'école des Sorciers" has been removed from the bookbox "Box1" !');

        // re-add the book to the book box for next test suite
        await server.inject({
            method: 'POST',
            url: `/books/add`,
            payload : {
                qrCodeId: `b1`,
                bookboxId : bbids[0]
            },
        });
    });
});


describe('Tests for thread creation and interaction', () => {

    test('Create a thread on a book', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/threads/new',
            payload: {
                bookId: portedBookId,
                title: "Discussion about the book",
                content: "What do you think about the book?"
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('threadId');
        portedThreadId = payload.threadId;
    });

    test('Add a message to a thread', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/threads/messages`,
            payload: {
                content: "I think the book is great!",
                threadId: portedThreadId,
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('messageId');
        portedMessageId = payload.messageId;
    });

    test('Add a message that responds to the precedent message', async () => {
        const newLogin = await server.inject({
            method: 'POST',
            url: '/users/login',
            payload: {
                identifier: 'testuser2',
                password: 'password'
            }
        });
        const newToken = JSON.parse(newLogin.payload).token;
        const response = await server.inject({
            method: 'POST',
            url: `/threads/messages`,
            payload: {
                content: "I agree with you!",
                respondsTo: portedMessageId,
                threadId: portedThreadId,
            },
            headers: {
                Authorization: `Bearer ${newToken}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(201);
        expect(payload).toHaveProperty('messageId');
    });

    test('React to a message', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/threads/messages/reactions`,
            payload: {
                reactIcon: 'link/to/like/icon',
                threadId: portedThreadId,
                messageId: portedMessageId
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('reaction');
        expect(payload.reaction.username).toBe('testuser');
    });

    test('Remove the reaction from the message', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/threads/messages/reactions`,
            payload: {
                reactIcon: 'link/to/like/icon',
                threadId: portedThreadId,
                messageId: portedMessageId
            },
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('reaction');
        expect(Object.keys(payload.reaction)).toHaveLength(0);
    });

    test('Search all threads', async () => {
        const response = await server.inject({
            method: 'GET',
            url: `/threads/search`
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('threads');
        expect(payload.threads).toHaveLength(1);
        expect(payload.threads[0].title).toBe('Discussion about the book');
    });

    test('Search a specific thread', async () => {
        const response = await server.inject({
            method: 'GET',
            url: `/threads/search?q=inexistence`
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('threads');
        expect(payload.threads).toHaveLength(0);
    });
});

async function getUser(token) {
    const response = await server.inject({
        method: 'GET',
        url: '/users',
        headers: {
            Authorization: `Bearer ${token}`
        }
    });
    return JSON.parse(response.payload).user;
}

afterAll(async () => {
    console.log('Tests done!');
    await reinitDatabase(server);
    await server.close();
});