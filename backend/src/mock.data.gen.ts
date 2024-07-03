import { faker } from '@faker-js/faker';


const url = "http://localhost:3000";
const bookBoxIds: string[] = [];
const bookIds: string[] = [];

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


async function populateUsers() {
    for (let i = 0; i < 10; i++) {
        await fetch(url + "/users/register", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify(randomUser())
        });
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
    // add 8 books to each book box
    for (let bookBoxId of bookBoxIds) {
        for (let i = 0; i < 8; i++) {
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

export async function populateDatabase() {
    await populateUsers();
    await populateBookBoxes();
    await populateBooks();
}
