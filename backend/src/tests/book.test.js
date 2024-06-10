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

describe('Test book exchanging by guest users', () => {
    let portedBookId;
    test('Adding a new book', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/book/6660ec640a7261afb1131165/add',
            payload: {
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
        expect(response.statusCode).toBe(200);
        expect(payload).toHaveProperty('bookId');
        expect(typeof payload.bookId).toBe('string');
        portedBookId = payload.bookId;
    });
    test('Removing a book from a book box', async () => {

    });
    test('Adding a book without title', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/book/6660ec640a7261afb1131165/add',
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
        expect(payload.error).toBe('Book\'s title is required');
    });
    test('Adding a book in an invalid bookBox', async () => {
        const response = await server.inject({
            method: 'POST',
            url: '/book/6660ec640a7213afb11a1c65/add',
            payload: { // No title
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
    });
});

afterAll(async () => {
    await server.close();
});