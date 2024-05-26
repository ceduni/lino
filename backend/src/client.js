const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function loginUser(username, password) {
    try {
        const response = await axios.post(`${BASE_URL}/user/login`, { username, password });
        console.log('User logged in:', response.data);
        return response.data;
    } catch (error) {
        console.error('Error logging in:', error.response.data);
    }
}

async function manageBook(loginData, isbn, bookboxId, action) {
    try {
        const response = await axios.post(`${BASE_URL}/book/${isbn}/${bookboxId}/${action}`, {}, {
            headers: {
                Authorization: `Bearer ${loginData.token}`
            }
        });
        console.log('Book action success:', response.data);
    } catch (error) {
        console.error('Error in book action:', error.response.data);
    }
}

async function createThread(loginData, isbn, title) {
    try {
        const response = await axios.post(`${BASE_URL}/threads`, { book_id: isbn, title, user_id: loginData.user._id }, {
            headers: {
                Authorization: `Bearer ${loginData.token}`
            }
        });
        console.log('Thread created:', response.data);
    } catch (error) {
        console.error('Error creating thread:', error.response.data);
    }
}

async function sendMessage(loginData, threadId, message) {
    try {
        const response = await axios.post(`${BASE_URL}/threads/${threadId}/messages`, { user_id: loginData.user._id, content : message }, {
            headers: {
                Authorization: `Bearer ${loginData.token}`
            }
        });
        console.log('Message sent:', response.data);
    } catch (error) {
        console.error('Error sending message:', error.response.data);
    }
}

(async function() {
    const username = 'Asp3rity';
    const password = 'J2s3jAsd';
    // Log in with the registered user
    const loginData = await loginUser(username, password);
    if (!loginData) {
        console.error('Login failed, exiting...');
        return;
    }

    await sendMessage(loginData, '665390530f9fe267f046aff5', 'Hello, world!');
})();
