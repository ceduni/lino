import User from '../models/user.model';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import { newErr } from "./utilities";

dotenv.config();

const UserService = {
    // User service to register a new user's account
    async registerUser(userData: any) {
        const { username, email, phone, password, getAlerted } = userData;
        if (username === 'guest') {
            throw newErr(400, 'Username not allowed');
        }

        // Check if username already exists
        if (!username) {
            throw newErr(400, 'Username is required');
        }
        const existingUser = await User.findOne({ username });
        if (existingUser) {
            throw newErr(400, 'Username already taken');
        }

        // Check if email already exists
        if (!email) {
            throw newErr(400, 'Email is required');
        }
        const existingEmail = await User.findOne({ email });
        if (existingEmail) {
            throw newErr(400, 'Email already taken');
        }

        if (!password) {
            throw newErr(400, 'Password is required');
        }
        const hashedPassword = await argon2.hash(password);
        const user = new User(
            { username : username,
                email : email,
                phone : phone,
                password: hashedPassword,
                getAlerted: getAlerted
            });
        await user.save();
        return {username: user.username, password: user.password};
    },

    // User service to log in a user if they exist (can log with either a username or an email)
    async loginUser(credentials: any) {
        const identifier = credentials.identifier;
        const user = await User.findOne({ $or: [{ username : identifier }, { email : identifier }]});
        if (!user) {
            throw newErr(400, 'Invalid username or email');
        }
        const validPassword = await argon2.verify(user.password, credentials.password);
        if (!validPassword) {
            throw newErr(400, 'Invalid password');
        }
        // User authenticated successfully, generate tokens
        // @ts-ignore
        const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY);

        return { user: user, token: token };
    },

    async readUserNotifications(request: any) {
        const userId = request.user.id;
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        // Calculate the date 30 days ago
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        // Filter out notifications older than 30 days
        // @ts-ignore
        user.notifications = user.notifications.filter(notification => {
            const notificationDate = new Date(notification.timestamp);
            return notificationDate >= thirtyDaysAgo;
        });

        // Set all remaining notifications to read
        user.notifications.forEach(notification => {
            notification.read = true;
        });

        // Save the updated user document
        await user.save();
        return user.notifications;
    },


    // User service to add a book's ID to a user's favorites
    async addToFavorites(request: any) {
        const userId = request.user.id;  // Extract user ID from JWT token
        const bookId = request.body.bookId;
        let user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (user.favoriteBooks.includes(bookId)) {
            throw newErr(400, 'Book already in favorites');
        }
        user.favoriteBooks.push(bookId);
        await user.save();
        return user;
    },


    // User service to remove a book's ID from a user's favorites
    async removeFromFavorites(request: any) {
        // @ts-ignore
        const userId = request.user.id;  // Extract user ID from JWT token
        // @ts-ignore
        const id = request.params.id;
        let user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        const index = user.favoriteBooks.indexOf(id);
        if (index === -1) { // Book not found in favorites
            throw newErr(404, 'Book not found in favorites');
        }
        user.favoriteBooks.splice(index, 1);
        await user.save();
        return user;
    },


    // User service to get the infos of the user's favorite books
    async getFavorites(userId: string) {
        let user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        // array to store the favorite books
        const favoriteBooks = [];
        for (const bookId of user.favoriteBooks) {
            // @ts-ignore
            const book = await Book.findById(bookId);
            if (book) {
                favoriteBooks.push(book);
            }
        }
        return favoriteBooks;
    },


    // User service to get the user's ecological impact
    async getEcologicalImpact(userId: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        return user.ecologicalImpact;
    },
    async getUserName(userId: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        return user.username;
    },
    async parseKeyWords(text: string) {
        return text.split(',');
    },

    async updateUser(request: any) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (request.body.username) {
            const check = await User.findOne({ username: request.body.username });
            if (check) {
                throw newErr(400, 'Username already taken');
            }
            user.username = request.body.username;
        }
        if (request.body.password) {
            user.password = await argon2.hash(request.body.password);
        }
        if (request.body.email) {
            const check = await User.findOne({ email: request.body.email });
            if (check) {
                throw newErr(400, 'Email already taken');
            }
            user.email = request.body.email;
        }
        if (request.body.phone) {
            user.phone = request.body.phone;
        }
        if (request.body.getAlerted) {
            user.getAlerted = request.body.getAlerted;
        }
        if (request.body.keyWords) {
            user.notificationKeyWords = await this.parseKeyWords(request.body.keyWords);
        }
        await user.save();
        return user;
    },

    async clearCollection() {
        await User.deleteMany({ username: { $ne: process.env.ADMIN_USERNAME } });
    }
};

export async function notifyUser(userId: string, title: string, message: string) {
    let user = await User.findById(userId);
    if (!user) {
        throw newErr(404, 'User not found');
    }
    const notification = { title : title, content: message, timestamp: new Date(), read: false };
    // Validate and push the notification into the user's notifications array
    try {
        user.notifications.push(notification); // Type assertion to avoid TypeScript errors
        await user.save();
    } catch (error : any) {
        throw new Error(`Failed to save notification: ${error.message}`);
    }

    return user;
}


export default UserService;