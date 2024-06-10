const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testRegister() {
    const username = 'Asp3rity';
    const email = 'natrazaf2020@gmail.com';
    const password = 'J2s3jAsd';
    try {
        const response = await axios.post(`${BASE_URL}/user/register`, {
            username,
            email,
            password
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testRegister2() {
    const username = 'Nathan';
    const email = 'natrazaf2022@gmail.com';
    const password = 'J2s3jAsd';
    try {
        const response = await axios.post(`${BASE_URL}/user/register`, {
            username,
            email,
            password
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testLogin2() {
    const identifier = 'Nathan';
    const password = 'J2s3jAsd';
    try {
        const response = await axios.post(`${BASE_URL}/user/login`, {
            identifier,
            password
        });
        console.log(response.data);
        return response.data.token;
    } catch (error) {
        console.error(error.response.data);
        return null;

    }
}

async function testAddKeyWords(token) {
    try {
        const response = await axios.post(`${BASE_URL}/user/keywords`,
            {
                keywords : "gatsby,charles,harry potter"
            }
            , {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testRemoveKeyWord(token) {
    try {
        const response = await axios.delete(`${BASE_URL}/user/keywords/charles`,
            {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testLogin() {
    const identifier = 'Asp3rity';
    const password = 'J2s3jAsd';
    try {
        const response = await axios.post(`${BASE_URL}/user/login`, {
            identifier,
            password
        });
        console.log(response.data);
        return response.data.token;
    } catch (error) {
        console.error(error.response.data);
        return null;

    }
}

async function testAddBook(token) {
    const bookBoxId = '6660ec640a7261afb1131165';
    const book = {
        title: 'The Great Gatsby',
        authors: ['F. Scott Fitzgerald'],
        description: 'The Great Gatsby is a novel written by American author F. Scott Fitzgerald that follows a cast of characters living in the fictional towns of West Egg and East Egg on prosperous Long Island in the summer of 1922.',
        categories: ['Fiction'],
        pages: 180,
        parutionYear: 1925,
        coverPage: 'https://d28hgpri8am2if.cloudfront.net/book_images/onix/cvr9781982146702/the-great-gatsby-9781982146702_lg.jpg',
        publisher: 'Scribner',
    }
    try {
            const response = await axios.post(`${BASE_URL}/book/${bookBoxId}/add`, book, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        return response.data.bookId;
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testRemoveBook(token, bookId) {
    const bookBoxId = '6660ec640a7261afb1131165';
    try {
        const response = await axios.post(`${BASE_URL}/book/${bookId}/${bookBoxId}/get`, {}, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testAddExistingBook(token, bookId) {
    const bookBoxId = '6660ff660a7261afb113117c';
    try {
        const response = await axios.post(`${BASE_URL}/book/${bookId}/${bookBoxId}/add`, {}, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        return response.data.book.title;
    } catch (error) {
        console.error(error.response.data);
    }

}

async function testAddToFavorites(token, bookId) {
    try {
        const response = await axios.post(`${BASE_URL}/user/favorites/${bookId}`, {},{
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testRemoveFromFavorites(token, bookId) {
    try {
        const response = await axios.delete(`${BASE_URL}/user/favorites/${bookId}`, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testCreateThread(token, bookTitle) {
    const thread = {
        book_title: bookTitle,
        title: 'The Great Gatsby Discussion || SPOILERS'
    }
    try {
        const response = await axios.post(`${BASE_URL}/threads/new`, thread, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
        return response.data;
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testAddMessage(token, threadId) {
    const message = {
        content: 'I love this book!'
    }
    try {
        const response = await axios.post(`${BASE_URL}/threads/${threadId}/messages`, message, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
        return response.data;
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testRespondToMessage(token, threadId, messageId) {
    const message = {
        content: 'I love it too! (I am the author of the previous message lmfao)',
        responds_to: messageId
    }
    try {
        const response = await axios.post(`${BASE_URL}/threads/${threadId}/messages`, message, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
        return response.data;
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testReactToMessage(token, threadId, messageId) {
    const reaction = {
        react_icon: '/path/to/laugh.png'
    }
    try {
        const response = await axios.post(`${BASE_URL}/threads/${threadId}/messages/${messageId}/reactions`, reaction, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        console.log(response.data);
    } catch (error) {
        console.error(error.response);
    }
}


async function gigaMainTest() {
    await clearCollections();
    // Register a new user
    await testRegister();
    console.log('Registration successful!');
    await delay(1000);
    // Register another user
    await testRegister2();
    console.log('Registration successful!');
    await delay(1000);
    // Log in with the registered user
    let token = await testLogin2();
    if (!token) {
        console.error('Login failed, exiting...');
        return;
    }
    console.log('Login successful! : ', token);
    await delay(1000);
    // Add keywords to the user's profile
    await testAddKeyWords(token);
    console.log('Keywords added successfully!');
    await delay(1000);
    // Remove a keyword from the user's profile
    await testRemoveKeyWord(token);
    console.log('Keyword removed successfully!');
    // Log in with the registered user
    token = await testLogin();
    if (!token) {
        console.error('Login failed, exiting...');
        return;
    }
    console.log('Login successful! : ', token);
    await delay(1000);
    // Add a book to the user's book box
    const bookId = await testAddBook(token);
    console.log('Book added successfully! : ', bookId);
    await delay(1000);
    // Remove the book from the user's book box
    await testRemoveBook(token, bookId);
    console.log('Book removed successfully!');
    await delay(1000);
    // Add the same book to the user's favorites
    await testAddToFavorites(token, bookId);
    console.log('Book added to favorites successfully!');
    await delay(1000);
    // Remove the book from the user's favorites
    await testRemoveFromFavorites(token, bookId);
    console.log('Book removed from favorites successfully!');
    await delay(1000);
    // Add the same book to the user's book box
    const bookTitle = await testAddExistingBook(token, bookId);
    console.log('Book added successfully! : ', bookTitle);
    await delay(1000);
    // Create a thread for the book
    const threadId = await testCreateThread(token, bookTitle);
    console.log('Thread created successfully! : ', threadId);
    await delay(1000);
    // Add a message to the thread
    const messageId = await testAddMessage(token, threadId);
    console.log('Message added successfully!');
    await delay(1000);
    // Log in with the registered user
    token = await testLogin2();
    if (!token) {
        console.error('Login failed, exiting...');
        return;
    }
    // Respond to the message
    const messageToReactId = await testRespondToMessage(token, threadId, messageId);
    console.log('Response added successfully!');
    await delay(1000);
    // React to the message
    await testReactToMessage(token, threadId, messageToReactId);
    console.log('Reaction added successfully!');
    await delay(1000);

}

async function testSearchBooks() {
    try {
        const bf = encodeURIComponent(true);
        const py = encodeURIComponent(1900);
        const cls = encodeURIComponent('by year');
        const asc = encodeURIComponent(false);
        const response = await axios.get(`${BASE_URL}/books/search?cls=${cls}&asc=${asc}`);
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}

async function testSearchThreads() {
    try {
        const q = encodeURIComponent('Spoilers');
        const response = await axios.get(`${BASE_URL}/threads/search?q=${q}`);
        console.log(response.data);
    } catch (error) {
        console.error(error.response.data);
    }
}


async function smolTest() {
    await testSearchBooks();
    await testSearchThreads();
    console.log('Search successful!');
}

gigaMainTest();





function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function clearCollections() {
    try {
        await axios.delete(`${BASE_URL}/user/clear`);
        await axios.delete(`${BASE_URL}/threads/clear`);
        await axios.delete(`${BASE_URL}/books/clear`);
        console.log('Collections cleared successfully!');
    } catch (error) {
        console.error('Failed to clear collections:', error.response.data);
    }
}