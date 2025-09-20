import { User } from '../models';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import { newErr } from "../utilities/utilities";
import { NotificationService } from '.';
import { getBoroughId } from '../utilities/borough.id.generator';

dotenv.config();

const UserService = {
    // User service to register a new user's account
    async registerUser(
        username: string,
        email: string,
        password: string,
        phone?: string,
    ) {
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

        const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY as string);

        return {username: user.username, email: user.email, token: token };
    },

    // User service to log in a user if they exist (can log with either a username or an email)
    async loginUser(identifier: string, password: string) {
        const user = await User.findOne({ $or: [{ username : identifier }, { email : identifier }]});
        if (!user) {
            throw newErr(400, 'Invalid username or email');
        }
        const validPassword = await argon2.verify(user.password, password);
        if (!validPassword) {
            throw newErr(400, 'Invalid password');
        }
        // User authenticated successfully, generate tokens
        const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY as string);

        return { username: user.username, email: user.email, token: token };
    },

    async getUserNotifications(id: string) {
        return await NotificationService.getUserNotifications(id);
    },


    async readNotification(id: string, notificationId: string) {
        return await NotificationService.readNotification(id, notificationId);
    },


    async getUserName(userId: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        return user.username;
    },

    
    async getUser(id: string) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        return user;
    },

    async addProfilePicture(id: string, profilePictureUrl: string) {
        console.log(`UserService: Adding profile picture for user ${id}: ${profilePictureUrl}`);
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        console.log(`UserService: User found, current profilePictureUrl: ${user.profilePictureUrl}`);
        user.profilePictureUrl = profilePictureUrl;
        await user.save();
        console.log(`UserService: User saved with new profilePictureUrl: ${user.profilePictureUrl}`);
        return user;
    },


    async updateUser(
        id: string,
        username?: string,
        password?: string,
        email?: string,
        phone?: string,
        favouriteGenres?: string[]
    ) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (username) {
            const check = await User.findOne({ username: username });
            if (check && check.username !== user.username) {
                throw newErr(400, 'Username already taken');
            }
            user.username = username;
        }
        if (password) {
            user.password = await argon2.hash(password);
        }
        if (email && email !== user.email) {
            const check = await User.findOne({ email: email });
            if (check) {
                throw newErr(400, 'Email already taken');
            }
            user.email = email;
        }
        if (phone) {
            user.phone = phone;
        }
        if (favouriteGenres) {
            user.favouriteGenres = favouriteGenres;
        }
        await user.save();
        return user;
    },


    async addUserFavLocation(
        id: string,
        latitude: number,
        longitude: number,
        name: string,
        tag?: string    
    ) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        if (!latitude || !longitude || !name) {
            throw newErr(400, 'Latitude, longitude and name are required');
        }

        // Get borough ID from coordinates
        const boroughId = await getBoroughId(latitude, longitude);
        user.favouriteLocations.push({
            latitude: latitude,
            longitude: longitude,
            name: name,
            boroughId: boroughId,
            tag: tag // Optional tag for the location
        });
        
        await user.save();
        return { 
            latitude: latitude, 
            longitude: longitude, 
            boroughId: boroughId, 
            name: name,
            tag: tag // Return the tag if provided
        };
    },


    async deleteUserFavLocation(
        id: string,
        name: string
    ) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }   
        if (!name) {
            throw newErr(400, 'Name is required');
        }
        // Find the index of the location to remove
        const index = user.favouriteLocations.findIndex(location => location.name === name);
        if (index === -1) {
            throw newErr(404, 'Location not found in favourites');
        }
        // Remove the location from the array
        user.favouriteLocations.splice(index, 1);   
        await user.save();
    },


    async toggleAcceptedNotificationType(
        id: string,
        type: string    ) {
        const user = await User.findById(id);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        if (!user.notificationSettings) {
            user.notificationSettings = {
                addedBook: true,
                bookRequested: true
            };
        }
        if (type === 'addedBook') {
            user.notificationSettings.addedBook = !user.notificationSettings.addedBook;
        } else if (type === 'bookRequested') {
            user.notificationSettings.bookRequested = !user.notificationSettings.bookRequested;
        } else {
            throw newErr(400, 'Invalid notification type');
        }
        await user.save();
        return user.notificationSettings;
    },


    async clearCollection() {
        await User.deleteMany({ username: { $ne: process.env.ADMIN_USERNAME } });
    },


    async clearNotifications() {
        await NotificationService.clearCollection();
        return { message: 'Notifications cleared' };
    }
};

export default UserService;
