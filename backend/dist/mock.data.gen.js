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
Object.defineProperty(exports, "__esModule", { value: true });
exports.populateDatabase = void 0;
const faker_1 = require("@faker-js/faker");
const url = "http://localhost:3000";
const bookBoxIds = [];
const bookIds = [];
const userIdentifiers = [];
const reactions = ['like', 'love', 'laugh', 'sad', 'angry'];
function randomUser() {
    return {
        username: faker_1.faker.internet.userName(),
        email: faker_1.faker.internet.email(),
        phone: faker_1.faker.phone.number(),
        password: faker_1.faker.internet.password(),
    };
}
function randomBookBox() {
    return {
        name: faker_1.faker.lorem.word(),
        longitude: faker_1.faker.location.longitude(),
        latitude: faker_1.faker.location.latitude(),
        image: faker_1.faker.image.url(),
        infoText: faker_1.faker.lorem.sentence(),
    };
}
function randomISBN() {
    const realISBNs = [
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
    return realISBNs[faker_1.faker.number.int({ min: 0, max: realISBNs.length - 1 })];
}
function randomBook() {
    return __awaiter(this, void 0, void 0, function* () {
        const isbn = randomISBN(); // Generate a random 13-digit ISBN
        const r = yield fetch(url + `/books/${isbn}`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
        });
        if (r.status === 200) {
            const book = yield r.json();
            return {
                isbn: isbn,
                qrCodeId: faker_1.faker.string.uuid(), // Generate a random UUID
                title: book.title, // Use the title from the API
                authors: book.authors, // Use the authors from the API
                description: book.description, // Use the description from the API
                coverImage: book.coverImage, // Use the cover image from the API
                publisher: book.publisher, // Use the publisher from the API
                categories: book.categories, // Use the categories from the API
                parutionYear: book.parutionYear, // Use the parution year from the API
                pages: book.pages, // Use the number of pages from the API
            };
        }
        else {
            return {
                isbn: isbn,
                qrCodeId: faker_1.faker.string.uuid(), // Generate a random UUID
                title: faker_1.faker.lorem.words(), // Generate a random title
                authors: Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => faker_1.faker.person.fullName()), // Generate an array of random author names with a length between 1 and 3
                description: faker_1.faker.lorem.paragraph(), // Generate a random description
                coverImage: faker_1.faker.image.url(), // Generate a random image URL
                publisher: faker_1.faker.company.name(), // Generate a random publisher name
                categories: Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => faker_1.faker.lorem.word()), // Generate an array of random category names with a length between 1 and 3
                parutionYear: faker_1.faker.number.int({ min: 1600, max: 2022 }), // Generate a random year between 1600 and 2022
                pages: faker_1.faker.number.int({ min: 50, max: 1000 }), // Generate a random number of pages between 50 and 1000
            };
        }
    });
}
function randomThread(bookId) {
    return {
        bookId: bookId,
        title: faker_1.faker.lorem.words(4),
    };
}
function randomMessage(threadId, respondsTo = null) {
    return {
        threadId: threadId,
        content: faker_1.faker.lorem.paragraph(),
        respondsTo: respondsTo,
    };
}
function populateUsers() {
    return __awaiter(this, void 0, void 0, function* () {
        for (let i = 0; i < 10; i++) {
            const user = randomUser();
            yield fetch(url + "/users/register", {
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
    });
}
function populateBookBoxes() {
    return __awaiter(this, void 0, void 0, function* () {
        // first connect as the administrator
        const init = yield fetch(url + "/users/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({
                identifier: process.env.ADMIN_USERNAME,
                password: process.env.ADMIN_PASSWORD,
            })
        });
        const { token } = yield init.json();
        // then create the book boxes (8)
        for (let i = 0; i < 8; i++) {
            const response = yield fetch(url + "/books/bookbox/new", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                    "Authorization": "Bearer " + token,
                },
                body: JSON.stringify(randomBookBox())
            });
            const { _id } = yield response.json();
            bookBoxIds.push(_id.toString());
        }
        console.log("Book boxes created");
    });
}
function populateBooks() {
    return __awaiter(this, void 0, void 0, function* () {
        // add between 3 and 5 books to each book box
        for (let bookBoxId of bookBoxIds) {
            const nBooks = faker_1.faker.number.int({ min: 3, max: 5 });
            for (let i = 0; i < nBooks; i++) {
                const response = yield fetch(url + "/books/add", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(Object.assign({ bookboxId: bookBoxId }, yield randomBook()))
                });
                const { bookId } = yield response.json();
                bookIds.push(bookId.toString());
            }
        }
        console.log("Books created");
    });
}
function populateThreads() {
    return __awaiter(this, void 0, void 0, function* () {
        // add between 0 and 2 threads to each book
        for (let bookId of bookIds) {
            // first connect a random user
            const { identifier, password } = userIdentifiers[faker_1.faker.number.int({ min: 0, max: 9 })];
            const response = yield fetch(url + "/users/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                },
                body: JSON.stringify({ identifier, password })
            });
            const { token: userToken } = yield response.json();
            const nThreads = faker_1.faker.number.int({ min: 0, max: 2 });
            for (let i = 0; i < nThreads; i++) {
                const response = yield fetch(url + "/threads/new", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                        "Authorization": "Bearer " + userToken,
                    },
                    body: JSON.stringify(randomThread(bookId))
                });
                const { threadId } = yield response.json();
                // add between 2 and 5 messages to each thread, which responds to the previous message with a probability of 0.5
                const nMessages = faker_1.faker.number.int({ min: 2, max: 5 });
                let respondsTo = null;
                for (let j = 0; j < nMessages; j++) {
                    if (faker_1.faker.number.float({ min: 0, max: 1 }) < 0.2) {
                        respondsTo = null;
                    }
                    // connect a random user
                    const { identifier, password } = userIdentifiers[faker_1.faker.number.int({ min: 0, max: 9 })];
                    const response0 = yield fetch(url + "/users/login", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json; charset=UTF-8",
                        },
                        body: JSON.stringify({ identifier, password })
                    });
                    const { token: otherUserToken } = yield response0.json();
                    const response = yield fetch(url + "/threads/messages", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json; charset=UTF-8",
                            "Authorization": "Bearer " + otherUserToken,
                        },
                        body: JSON.stringify(randomMessage(threadId, respondsTo))
                    });
                    const { messageId } = yield response.json();
                    respondsTo = messageId;
                    if (faker_1.faker.number.float({ min: 0, max: 1 }) < 0.5) {
                        // add a reaction to the message
                        yield fetch(url + "/threads/messages/reactions", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json; charset=UTF-8",
                                "Authorization": "Bearer " + otherUserToken,
                            },
                            body: JSON.stringify({
                                reactIcon: reactions[faker_1.faker.number.int({ min: 0, max: 4 })],
                                threadId: threadId,
                                messageId: messageId,
                            })
                        });
                    }
                }
            }
        }
        console.log("Threads created");
    });
}
function populateDatabase() {
    return __awaiter(this, void 0, void 0, function* () {
        yield populateUsers();
        yield populateBookBoxes();
        yield populateBooks();
        yield populateThreads();
        console.log("Database populated!");
    });
}
exports.populateDatabase = populateDatabase;
