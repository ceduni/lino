import { faker } from '@faker-js/faker';


const url = "https://lino-1.onrender.com";
const bookBoxIds: string[] = [];
const bookIds: string[] = [];
const userIdentifiers: any[] = [];
const reactions: string[] = ['like', 'love', 'laugh', 'sad', 'angry'];

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
        image: faker.image.url(),
        infoText: faker.lorem.sentence(),
    }
}

function randomISBN(): string {
    // Helper function to generate a random integer within a given range
    function getRandomInt(min: number, max: number): number {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    // Generate the first 12 digits of the ISBN
    const prefix = getRandomInt(0, 1) === 0 ? '978' : '979';
    const registrationGroup = getRandomInt(0, 5).toString().padStart(1, '0');
    const registrant = getRandomInt(0, 99999).toString().padStart(5, '0');
    const publication = getRandomInt(0, 99999).toString().padStart(5, '0');

    // Combine the parts to form the first 12 digits of the ISBN
    const isbnWithoutCheck = (prefix + registrationGroup + registrant + publication).substring(0, 12);

    // Calculate the check digit
    let total = 0;
    for (let i = 0; i < isbnWithoutCheck.length; i++) {
        const digit = parseInt(isbnWithoutCheck.charAt(i));
        total += i % 2 === 0 ? digit : digit * 3;
    }
    const checkDigit = (10 - (total % 10)) % 10;

    // Combine the first 12 digits with the check digit to form the complete ISBN
    return isbnWithoutCheck + checkDigit.toString();
}

async function randomBook() {
    const isbn = randomISBN(); // Generate a random 13-digit ISBN
    const r = await fetch(url + `/books/${isbn}`, {
        method: "GET",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
    });
    if (r.status === 200) {
        const book = await r.json();
        return {
            isbn: isbn,
            qrCodeId: faker.string.uuid(), // Generate a random UUID
            title: book.title, // Use the title from the API
            authors: book.authors, // Use the authors from the API
            description: book.description, // Use the description from the API
            coverImage: book.coverImage, // Use the cover image from the API
            publisher: book.publisher, // Use the publisher from the API
            categories: book.categories, // Use the categories from the API
            parutionYear: book.parutionYear, // Use the parution year from the API
            pages: book.pages, // Use the number of pages from the API
        }
    } else {
        return {
            isbn: isbn,
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
            parutionYear: faker.number.int({min: 1600, max: 2022}), // Generate a random year between 1600 and 2022
            pages: faker.number.int({min: 50, max: 1000}), // Generate a random number of pages between 50 and 1000
        }
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

    // then create the book boxes (8)
    for (let i = 0; i < 8; i++) {
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
                    ...await randomBook(),
                })
            });
            const { bookId } = await response.json();
            bookIds.push(bookId.toString());
        }
    }
    console.log("Books created");
}

async function populateThreads() {
    // add between 0 and 2 threads to each book
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
        const nThreads = faker.number.int({min: 0, max: 2});
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

            // add between 2 and 5 messages to each thread, which responds to the previous message with a probability of 0.5
            const nMessages = faker.number.int({min: 2, max: 5});
            let respondsTo = null;
            for (let j = 0; j < nMessages; j++) {
                if (faker.number.float({min: 0, max: 1}) < 0.2) {
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

                if (faker.number.float({min: 0, max: 1}) < 0.5) {
                    // add a reaction to the message
                    await fetch(url + "/threads/messages/reactions", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json; charset=UTF-8",
                            "Authorization": "Bearer " + otherUserToken,
                        },
                        body: JSON.stringify({
                            reactIcon: reactions[faker.number.int({min: 0, max: 4})],
                            threadId: threadId,
                            messageId: messageId,
                        })
                    });
                }
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
