import { faker } from '@faker-js/faker';
import dotenv from 'dotenv';
dotenv.config();


// const url = 'https://lino-1.onrender.com';
const url = 'http://localhost:3000';

async function getAdminToken() {
    const response = await fetch(`${url}/users/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            identifier: process.env.ADMIN_USERNAME, 
            password: process.env.ADMIN_PASSWORD 
        })
    });
    if (!response.ok) {
        throw new Error('Failed to fetch admin token');
    }
    const data = await response.json();
    return data.token;
}

async function generateTransaction(
    username,
    bookTitle,
    bookboxId,
    action = null, // 'added' or 'took', if null it will be randomly chosen
    day = null, // Date in "YYYY-MM-DD" format, if null it will be randomly chosen
    hour = null // Time in "HH:MM" format, if null it will be randomly chosen
) {
    // Random action
    if (!action) {
        action = Math.random() < 0.5 ? 'added' : 'took';
    }
    // Random date within the last 365 days
    const randomDaysAgo = Math.floor(Math.random() * 365);
    const date = new Date();
    date.setDate(date.getDate() - randomDaysAgo);
    // Random hour and minute
    const randomHour = Math.floor(Math.random() * 24);
    const randomMinute = Math.floor(Math.random() * 60);
    date.setHours(randomHour, randomMinute, 0, 0);

    // Format day as "YYYY-MM-DD"
    if (!day) {
        day = date.toISOString().split('T')[0];
    }
    // Format hour as "HH:MM"
    if (!hour) {
        hour = date.toTimeString().slice(0, 5);
    }
   // Create transaction object
   const transaction = {
       username,
       bookTitle,
       bookboxId,
       action,
       day,
       hour
   };

   return transaction;
}

async function submitTransaction(token, transaction) {
    const response = await fetch(`${url}/transactions/custom`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(transaction)
    });
    if (!response.ok) {
        console.error('Error submitting transaction:', response.statusText);
        throw new Error('Failed to submit transaction');
    }
    const r = await response.json();
    return r;
}

async function getBookboxes() {
    const response = await fetch(`${url}/bookboxes/search`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });
    if (!response.ok) {
        throw new Error('Failed to fetch bookboxes');
    }
    const r = await response.json();
    return r['bookboxes'];
}

async function populateTransactions(selectedDay = null) {
    try {
        const bookboxes = await getBookboxes();
        const adminToken = await getAdminToken();
        if (!bookboxes || bookboxes.length === 0) {
            console.error('No bookboxes found');
            return;
        }

        const transactions = [];
        let limit;
        if (selectedDay) {
            // If a specific day is selected, limit to 50 transactions
            limit = 50;
        } else {
            // Otherwise, generate 500 transactions
            limit = 200;
        }
        for (let i = 0; i < limit; i++) {
            const username = faker.internet.userName();
            const bookTitle = faker.lorem.words(3);
            const bookboxId = bookboxes[Math.floor(Math.random() * bookboxes.length)].id;

            let transaction;
            if (selectedDay) {
                // Use the selected day for all transactions
                transaction = await generateTransaction(username, bookTitle, bookboxId, null, selectedDay);
            } else {
                // Generate a random transaction
                transaction = await generateTransaction(username, bookTitle, bookboxId);
            }
            await submitTransaction(adminToken, transaction);
            console.log(`Transaction ${i + 1} submitted:`, transaction);
            transactions.push(transaction);
        }
    } catch (error) {
        console.error('Error populating transactions:', error);
    }
}

populateTransactions("2025-02-30")
    .then(() => console.log('Transaction generation completed'))
    .catch(error => console.error('Error in transaction generation:', error));

