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
        infoText: faker_1.faker.lorem.sentence(),
    };
}
function randomBook() {
    return {
        isbn: faker_1.faker.string.numeric(13), // Generate a random 13-digit ISBN
        qrCodeId: faker_1.faker.string.uuid(), // Generate a random UUID
        title: faker_1.faker.lorem.words(), // Generate a random title
        authors: Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => faker_1.faker.person.fullName()), // Generate an array of random author names with a length between 1 and 3
        description: faker_1.faker.lorem.paragraph(), // Generate a random description
        coverImage: faker_1.faker.image.url(), // Generate a random image URL
        publisher: faker_1.faker.company.name(), // Generate a random publisher name
        categories: Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => faker_1.faker.lorem.word()), // Generate an array of random category names with a length between 1 and 3
        parutionYear: faker_1.faker.date.past().getFullYear(), // Generate a random past year for parutionYear
        pages: faker_1.faker.number.int({ min: 50, max: 1000 }), // Generate a random number of pages between 50 and 1000
    };
}
function populateUsers() {
    return __awaiter(this, void 0, void 0, function* () {
        for (let i = 0; i < 10; i++) {
            yield fetch(url + "/users/register", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8",
                },
                body: JSON.stringify(randomUser())
            });
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
        // then create the book boxes
        for (let i = 0; i < 10; i++) {
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
        // add 8 books to each book box
        for (let bookBoxId of bookBoxIds) {
            for (let i = 0; i < 8; i++) {
                const response = yield fetch(url + "/books/add", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=UTF-8",
                    },
                    body: JSON.stringify(Object.assign({ bookboxId: bookBoxId }, randomBook()))
                });
                const { bookId } = yield response.json();
                bookIds.push(bookId.toString());
            }
        }
        console.log(bookIds);
        console.log("Books created");
    });
}
function populateDatabase() {
    return __awaiter(this, void 0, void 0, function* () {
        yield populateUsers();
        yield populateBookBoxes();
        yield populateBooks();
    });
}
exports.populateDatabase = populateDatabase;
