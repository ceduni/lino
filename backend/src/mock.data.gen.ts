import { faker } from '@faker-js/faker';


const url = "https://lino-1.onrender.com";
const bookBoxIds: string[] = [];
const bookIds: string[] = [];
const userIdentifiers: any[] = [];
var bookIndex = 0;
const bookISBNs = [
    "9780061120084", // To Kill a Mockingbird
    "9780451524935", // 1984
    "9781503290563", // Pride and Prejudice
    "9780743273565", // The Great Gatsby
    "9781503280786", // Moby-Dick
    "9781853260629", // War and Peace
    "9780316769488", // The Catcher in the Rye
    "9780547928227", // The Hobbit
    "9781451673319", // Fahrenheit 451
    "9780141441146", // Jane Eyre
    "9780060850524", // Brave New World
    "9780141439556", // Wuthering Heights
    "9780451526342", // Animal Farm
    "9780374528379", // The Brothers Karamazov
    "9780486415871", // Crime and Punishment
    "9780143128564", // The Grapes of Wrath
    "9780142437230", // Great Expectations
    "9780486280615", // The Adventures of Huckleberry Finn
    "9780140283334", // The Odyssey
    "9780143039433", // The Iliad
    "9780140449112", // The Aeneid
    "9780140449242", // The Divine Comedy
    "9780375758997", // The Old Man and the Sea
    "9780553213119", // Dracula
    "9780141439600", // Frankenstein
    "9780142424179", // The Fault in Our Stars
    "9780307269751", // The Road
    "9780143128571", // East of Eden
    "9780345803481", // Fifty Shades of Grey
    "9780679783268", // The Picture of Dorian Gray
    "9780307474278", // Life of Pi
    "9780143035008", // A Tale of Two Cities
    "9780143111580", // On the Road
    "9780743297332", // The Da Vinci Code
    "9780062024039", // Divergent
    "9780307588371", // The Girl with the Dragon Tattoo
    "9781594489501", // The Kite Runner
    "9780451526922", // The Scarlet Letter
    "9780141442433", // Tess of the d'Urbervilles
    "9780062316097"  // The Alchemist
];


function randomUser() {
    return {
        username: faker.internet.userName(),
        email: faker.internet.email(),
        phone: faker.phone.number(),
        password: faker.internet.password(),
    }
}

function randomBookBox() {
    const campusBounds = {
        north: 45.5048,
        south: 45.4990,
        west: -73.6195,
        east: -73.6110
    };

    return {
        name: faker.lorem.word(),
        longitude: faker.number.float({
            min: campusBounds.west,
            max: campusBounds.east,
            fractionDigits: 6,
        }),
        latitude: faker.number.float({
            min: campusBounds.south,
            max: campusBounds.north,
            fractionDigits: 6,
        }),
        image: faker.image.url(),
        infoText: faker.lorem.sentence(),
    }
}


async function randomBook(isbn: string) {
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
    for (let i = 0; i < bookBoxIds.length; i++) {
        const nBooks = i == bookBoxIds.length - 1 ? 40 - bookIndex : faker.number.int({min: 3, max: 5});
        for (let i = 0; i < nBooks; i++) {
            const response = await fetch(url + "/books/add", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                },
                body: JSON.stringify({
                    bookboxId: bookBoxIds[i],
                    ...await randomBook(bookISBNs[bookIndex++]),
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
            const nMessages = faker.number.int({min: 2, max: 3});
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
