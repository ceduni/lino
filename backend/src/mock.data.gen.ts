import { faker } from '@faker-js/faker';


const url = "https://lino-1.onrender.com";
const bookBoxIds: string[] = [];
const bookIds: string[] = [];
const userIdentifiers: any[] = [];

function randomUser() {
    return {
        username: faker.internet.userName(),
        email: faker.internet.email(),
        phone: faker.phone.number(),
        password: faker.internet.password(),
    }
}

function randomBookBox() {
    return {
        name: faker.lorem.word(),
        longitude: faker.location.longitude(),
        latitude: faker.location.latitude(),
        infoText: faker.lorem.sentence(),
    }
}

function randomBook() {
    return {
        isbn: faker.string.numeric(13), // Generate a random 13-digit ISBN
        qrCodeId: faker.string.uuid(), // Generate a random UUID
        title: faker.lorem.words(), // Generate a random title
        authors: Array.from(
            { length: faker.number.int({min: 1, max: 3}) },
            () => faker.person.fullName()
        ), // Generate an array of random author names with a length between 1 and 3
        description: faker.lorem.paragraph(), // Generate a random description
        coverImage: faker.image.url(), // Generate a random image URL
        publisher: faker.company.name(), // Generate a random publisher name
        categories: Array.from(
            { length: faker.number.int({min: 1, max: 3}) },
            () => faker.lorem.word()
        ), // Generate an array of random category names with a length between 1 and 3
        parutionYear: faker.date.past().getFullYear(), // Generate a random past year for parutionYear
        pages: faker.number.int({min: 50, max: 1000}), // Generate a random number of pages between 50 and 1000
    }
}

function randomThread(bookId: string) {
    return {
        bookId: bookId,
        title: faker.lorem.words(4),
    }
}

function randomMessage(threadId: string, respondsTo: string | null = null) {
    return {
        threadId: threadId,
        content: faker.lorem.paragraph(),
        respondsTo: respondsTo,
    }
}

async function populateUsers() {
    for (let i = 0; i < 10; i++) {
        const user = randomUser();
        await fetch(url + "/users/register", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify(user)
        });
        const { username, password } = user;
        userIdentifiers.push({ identifier: username, password: password });
    }
    console.log("Users created");
}

async function populateBookBoxes() {
    // first connect as the administrator
    const init = await fetch(url + "/users/login", {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({
            identifier: process.env.ADMIN_USERNAME,
            password: process.env.ADMIN_PASSWORD,
        })
    });
    const { token } = await init.json();

    // then create the book boxes
    for (let i = 0; i < 10; i++) {
        const response = await fetch(url + "/books/bookbox/new", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
                "Authorization": "Bearer " + token,
            },
            body: JSON.stringify(randomBookBox())
        });
        const { _id } = await response.json();
        bookBoxIds.push(_id.toString());
    }
    console.log("Book boxes created");
}

async function populateBooks() {
    // add between 3 and 5 books to each book box
    for (let bookBoxId of bookBoxIds) {
        const nBooks = faker.number.int({min: 3, max: 5});
        for (let i = 0; i < nBooks; i++) {
            const response = await fetch(url + "/books/add", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                },
                body: JSON.stringify({
                    bookboxId: bookBoxId,
                    ...randomBook(),
                })
            });
            const { bookId } = await response.json();
            bookIds.push(bookId.toString());
        }
    }
    console.log("Books created");
}

async function populateThreads() {
    // add between 1 and 2 threads to each book
    for (let bookId of bookIds) {
        // first connect a random user
        const { identifier, password } = userIdentifiers[faker.number.int({min: 0, max: 9})];
        const response = await fetch(url + "/users/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({ identifier, password })
        });
        const { token : userToken } = await response.json();
        const nThreads = faker.number.int({min: 1, max: 3});
        for (let i = 0; i < nThreads; i++) {
            const response = await fetch(url + "/threads/new", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                    "Authorization": "Bearer " + userToken,
                },
                body: JSON.stringify(randomThread(bookId))
            });
            const { threadId } = await response.json();

            // add between 1 and 5 messages to each thread, which responds to the previous message with a probability of 0.5
            const nMessages = faker.number.int({min: 3, max: 7});
            let respondsTo = null;
            for (let j = 0; j < nMessages; j++) {
                if (faker.number.float({min: 0, max: 1}) < 0.6) {
                    respondsTo = null;
                }
                // connect a random user
                const { identifier, password } = userIdentifiers[faker.number.int({min: 0, max: 9})];
                const response0 = await fetch(url + "/users/login", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify({ identifier, password })
                });
                const { token : otherUserToken } = await response0.json();
                const response : any = await fetch(url + "/threads/messages", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                        "Authorization": "Bearer " + otherUserToken,
                    },
                    body: JSON.stringify(randomMessage(threadId, respondsTo))
                });
                const { messageId } = await response.json();
                respondsTo = messageId;
            }
        }
    }
    console.log("Threads created");
}

export async function populateDatabase() {
    await populateUsers();
    await populateBookBoxes();
    await populateBooks();
    await populateThreads();
    console.log("Database populated!");
}
