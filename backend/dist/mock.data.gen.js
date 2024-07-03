"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.randomBookBox = exports.randomBook = void 0;
const faker_1 = require("@faker-js/faker");
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
exports.randomBook = randomBook;
function randomBookBox() {
    return {
        name: faker_1.faker.lorem.word(),
        location: [faker_1.faker.location.latitude(), faker_1.faker.location.longitude()],
        infoText: faker_1.faker.lorem.sentence(),
        books: [],
    };
}
exports.randomBookBox = randomBookBox;
