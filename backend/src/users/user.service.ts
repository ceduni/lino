import User from './user.model';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import { newErr } from "../services/utilities";
import NotificationService from '../notifications/notification.service';
import { getBoroughId } from '../services/borough.id.generator';
import AdminService from '../admins/admin.service';
import { 
    UserRegistrationData, 
    UserLoginCredentials, 
    IUser
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

        const token = jwt.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY as string);

        return {username: user.username, email: user.email, token: token };
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
        return await NotificationService.getUserNotifications(request);
    },

    async readNotification(request: AuthenticatedRequest & { body: { notificationId: string } }) {
        return await NotificationService.readNotification(request);
    },


    async getUserName(userId: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw newErr(404, 'User not found');
        }
        return user.username;
    },
    async updateUser(request: AuthenticatedRequest & { 
        body: { 
            username?: string; 
            password?: string; 
            email?: string; 
            phone?: string; 
            favouriteGenres?: string[];
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
        if (request.body.favouriteGenres) {
            user.favouriteGenres = request.body.favouriteGenres;
        }
        await user.save();
        return user;
    },

    async addUserFavLocation(request: AuthenticatedRequest & { 
        body: { 
            latitude: number; 
            longitude: number;
            name: string; // Name of the location
            tag?: string; // Optional tag for the location
        } 
    }) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }

        const { latitude, longitude, name } = request.body;
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
            tag: request.body.tag // Optional tag for the location
        });
        
        await user.save();
        return { 
            latitude: latitude, 
            longitude: longitude, 
            boroughId: boroughId, 
            name: name,
            tag: request.body.tag // Return the tag if provided
        };
    },

    async deleteUserFavLocation(request: AuthenticatedRequest & { 
        body: { 
            name: string;
        } 
    }) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw newErr(404, 'User not found');
        }   
        const { name } = request.body;
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

    async clearCollection() {
        await User.deleteMany({ username: { $ne: process.env.ADMIN_USERNAME } });
    },

    async clearNotifications() {
        await NotificationService.clearCollection();
        return { message: 'Notifications cleared' };
    }
};

export default UserService;
