import User from '../models/user.model';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import { newErr } from "./utilities";
import {broadcastToUser} from '../index';
import { 
    UserRegistrationData, 
    UserLoginCredentials, 
    IUser,
    INotification 
} from '../types/user.types';
import { AuthenticatedRequest } from '../types/common.types';

dotenv.config();

const UserService = {
    // User service to register a new user's account
    async registerUser(userData: UserRegistrationData) {
        const { username, email, phone, password } = userData;
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
                password: hashedPassword
            });
        await user.save();
        return {username: user.username, password: user.password};
    },

    // User service to log in a user if they exist (can log with either a username or an email)
    async loginUser(credentials: UserLoginCredentials) {
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
        const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY as string);

        return { user: user, token: token };
    },

    async getUserNotifications(request: AuthenticatedRequest) {
        const userId = request.user.id;
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        // Calculate the date 30 days ago
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        // Filter out notifications older than 30 days
        const filteredNotifications = user.notifications.filter(notification => {
            const notificationDate = new Date(notification.timestamp);
            return notificationDate >= thirtyDaysAgo;
        });
        user.notifications = filteredNotifications as any;

        // Save the updated user document
        await user.save();
        return user.notifications;
    },

    async readNotification(request: AuthenticatedRequest & { body: { notificationId: string } }) {
        const userId = request.user.id;
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        const notificationId = request.body.notificationId;
        const notification = user.notifications.id(notificationId);
        if (!notification) {
            throw newErr(404, 'Notification not found');
        }
        notification.read = true;
        await user.save();
        return user.notifications;
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

    async updateUser(request: AuthenticatedRequest & { 
        body: { 
            username?: string; 
            password?: string; 
            email?: string; 
            phone?: string; 
            keyWords?: string; 
        } 
    }) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (request.body.username) {
            const check = await User.findOne({ username: request.body.username });
            if (check && check.username !== user.username) {
                throw newErr(400, 'Username already taken');
            }
            user.username = request.body.username;
        }
        if (request.body.password) {
            user.password = await argon2.hash(request.body.password);
        }
        if (request.body.email && request.body.email !== user.email) {
            const check = await User.findOne({ email: request.body.email });
            if (check) {
                throw newErr(400, 'Email already taken');
            }
            user.email = request.body.email;
        }
        if (request.body.phone) {
            user.phone = request.body.phone;
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
    const notification: INotification = { title: title, content: message, timestamp: new Date(), read: false };

    // Validate and push the notification into the user's notifications array
    try {
        user.notifications.push(notification);
        await user.save();
    } catch (error: unknown) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        throw new Error(`Failed to save notification: ${errorMessage}`);
    }

    // Broadcast the notification to the user if they are connected via WebSocket
    broadcastToUser(userId, { event: 'newNotification', data: notification });

    return user;
}


export default UserService;
