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
            url: '/users/clear'
        });
        console.log('Collections cleared successfully!');
    } catch (error) {
        console.error('Failed to clear collections:', error.response.data);
    }
}

beforeAll(async () => {
    await clearCollections();
});

let portedBookId;
let portedThreadId;
let portedMessageId;
let token;
let portedBookIds = [];
let fakeQRCodeCounter = 0;

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
        expect(response.statusCode).toBe(401);
        expect(payload.error).toBe('Invalid credentials');
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
            payload: {
                bookboxId: "6660ec640a7261afb1131165",
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
            payload: { // No title
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
                bookboxId: "6660ec640a7213afb11a1c65",
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
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Bookbox not found');
        fakeQRCodeCounter--;
    });
});


describe('Test book fetching by guest users', () => {

    test('Getting a book from a book box', async () => {
        const response = await server.inject({
            method: 'GET',
            url: `/books/b0/6660ec640a7261afb1131165`
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
            url: `/books/b0/6660ec640a7261afb1131165`
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(400);
        expect(payload.error).toBe('Book not found in bookbox');
    });

    test('Adding an already registered book in another book box', async () => {
        const response = await server.inject({
            method: 'POST',
            url: `/books/add`,
            payload : {
                bookboxId: "6660ff660a7261afb113117c",
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
                bookboxId : "6660ec640a7261afb1131165",
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
            url: '/books/alert',
            headers: {
                Authorization: `Bearer ${token}`
            },
            payload: {
                title: 'Harry Potter à l\'école des sorciers',
            }
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('message');
        expect(payload.message).toBe("Alert sent");
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
                bookboxId : "6660ec640a7261afb1131165",
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
            url: `/books/b1/6660ec640a7261afb1131165`
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
                bookboxId : "6660ec640a7261afb1131165"
            },
        });
    });
});


describe('Test book searching among the database', () => {

    test('Search all books', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search'
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('books');
        expect(payload.books).toHaveLength(2);
        expect(payload.books[0].authors[0]).toBe('Victor Dixen');
        expect(payload.books[1].authors[0]).toBe('J.K. Rowling');
        expect(payload.books[0].bookboxPresence[0]).toBe('6660ff660a7261afb113117c');
        expect(payload.books[1].bookboxPresence[0]).toBe('6660ec640a7261afb1131165');
    });

    test('Add quite a lot of books for further testing', async () => {
        const isbns = [
            "9782075020893",
            "9781781101070",
            "9781781105542",
            "9781421581514",
            "9781421545257",
            "9782331009501",
            "9781421544328",
            "9781975319441",
            "9781974720286"
        ]
        const bbids = [
            "6660ec640a7261afb1131165",
            "6660ff660a7261afb113117c"
        ]

        for (let i = 0; i < isbns.length; i++) {
            const book = await server.inject({
                method: 'GET',
                url: `/books/${isbns[i]}`
            });
            const payload = JSON.parse(book.payload);
            const response = await server.inject({
                method: 'POST',
                url: `/books/add`, // alternate between the book boxes
                payload: {
                    qrCodeId: `b${fakeQRCodeCounter++}`,
                    bookboxId: bbids[i%bbids.length],
                    isbn: payload.isbn,
                    title: payload.title,
                    authors: payload.authors,
                    description: payload.description,
                    coverImage: payload.coverImage,
                    publisher: payload.publisher,
                    parutionYear: payload.parutionYear,
                    pages: payload.pages,
                    categories: payload.categories
                }
            });
            const responsePayload = JSON.parse(response.payload);
            expect(response.statusCode).toBe(201);
            expect(responsePayload).toHaveProperty('bookId');
            portedBookIds.push(responsePayload.bookId);
        }
    }, 10000);

    test('Search all books again, just to be sure', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search'
        });
        const payload = JSON.parse(response.payload);
        expect(response.statusCode).toBe(200);
        expect(payload.books.length).toBe(11);
    });

    test('Search specific books in specific order : ' +
        'in a specific book box, in the ascending alphabetical order of the 1st author\'s name', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search?bbid=6660ec640a7261afb1131165&asc=true&cls=by+author'
        });
        const payload = JSON.parse(response.payload);
        expect(payload).toHaveProperty('books');
        expect(payload.books).toHaveLength(6);
        for (let i = 0; i < payload.books.length-1; i++) {
            expect(payload.books[i].authors[0].localeCompare(payload.books[i+1].authors[0]))
                .toBeLessThanOrEqual(0);
        }
    });

    test('Search specific books in specific order : ' +
        'same as earlier but descending order', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search?bbid=6660ec640a7261afb1131165&asc=false&cls=by+author'
        });
        const payload = JSON.parse(response.payload);
        expect(payload).toHaveProperty('books');
        expect(payload.books).toHaveLength(6);
        for (let i = 0; i < payload.books.length-1; i++) {
            expect(payload.books[i].authors[0].localeCompare(payload.books[i+1].authors[0]))
                .toBeGreaterThanOrEqual(0);
        }
    });

    test('Search specific books in specific order : ' +
        'published after 2016, in the ascending alphabetical order of the title', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search?asc=true&cls=by+title&bf=false&py=2016'
        });
        const payload = JSON.parse(response.payload);
        expect(payload).toHaveProperty('books');
        for (let i = 0; i < payload.books.length-1; i++) {
            expect(payload.books[i].parutionYear).toBeGreaterThanOrEqual(2016);
            expect(payload.books[i].title[0].localeCompare(payload.books[i+1].title[0]))
                .toBeLessThanOrEqual(0);
        }
    });

    test('Search specific books in specific order : ' +
        'whose title or author contains "Harry", in the descending order of the parution year', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search?asc=false&cls=by+year&kw=Harry'
        });
        const payload = JSON.parse(response.payload);
        expect(payload).toHaveProperty('books');
        for (let i = 0; i < payload.books.length-1; i++) {
            expect(
                payload.books[i].title.includes('Harry')
                || payload.books[i].authors[0].includes('Harry')
            ).toBe(true);
            expect(payload.books[i].parutionYear).toBeGreaterThanOrEqual(payload.books[i+1].parutionYear);
        }
    });

    test('Search specific books in specific order : ' +
        'whose publisher is VIZ Media LLC, in the ascending order of the most recent activity', async () => {
        const response = await server.inject({
            method: 'GET',
            url: '/books/search?asc=true&cls=by+recent+activity&pub=VIZ+Media+LLC'
        });
        const payload = JSON.parse(response.payload);
        expect(payload).toHaveProperty('books');
        for (let i = 0; i < payload.books.length-1; i++) {
            expect(payload.books[i].publisher).toBe('VIZ Media LLC');
            const date1 = new Date(payload.books[i].dateLastAction);
            const date2 = new Date(payload.books[i+1].dateLastAction);
            expect(date1.getTime()).toBeLessThanOrEqual(date2.getTime());
        }
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
        expect(payload.reaction).toBe(null);
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
    await clearCollections();
    await server.close();
});