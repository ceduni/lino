import { faker } from '@faker-js/faker';


const url = "https://lino-1.onrender.com";
const bookBoxIds: string[] = [];
const bookIds: string[] = [];
const userIdentifiers: any[] = [];
const reactions: string[] = ['good', 'bad'];

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
    const realISBNs: string[] = [
        "9780316769488",
        "9780439139601",
        "9780439139595",
        "9780446310789",
        "9780061120084",
        "9780316015844",
        "9781400079988",
        "9780140283297",
        "9780375831003",
        "9780307474278",
        "9780743273565",
        "9780385490818",
        "9780142437230",
        "9780451524935",
        "9780060935467",
        "9780743234801",
        "9780307346605",
        "9780812981605",
        "9780812974492",
        "9780679785897",
        "9780140186390",
        "9780156012195",
        "9780812980196",
        "9780812982077",
        "9780307949486",
        "9780307277674",
        "9780385333499",
        "9780375725784",
        "9780345803481",
        "9780812995343",
        "9780143126560",
        "9780142437209",
        "9780679732761",
        "9780316769174",
        "9780679783275",
        "9780399501487",
        "9780374528379",
        "9780394716096",
        "9780345803924",
        "9780399590500",
        "9780143127550",
        "9780374533557",
        "9780143110439",
        "9780812988659",
        "9780307592736",
        "9780679760801",
        "9780385490628",
        "9780812979657",
        "9780307269751"
    ];
    return realISBNs[faker.number.int({min: 0, max: realISBNs.length - 1})];
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
    await fetch(url + "/users/register", {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({
            username: 'Asp3rity',
            email: faker.internet.email(),
            phone: faker.phone.number(),
            password: 'J2s3jAsd'
        })
    });
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
                            reactIcon: reactions[faker.number.int({min: 0, max: 1})],
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
