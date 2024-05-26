import User from '../models/user.model';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const UserService = {
    // User service to register a new user's account
    async registerUser(userData: any) {
        const { username, password } = userData;

        // Check if user already exists
        const existingUser = await User.findOne({ username });
        if (existingUser) {
            throw new Error('Username already taken');
        }

        const hashedPassword = await argon2.hash(password);
        const user = new User({ username, password: hashedPassword });
        await user.save();
        return user;
    },

    // User service to login a user if they exist
    async loginUser(credentials: any) {
        const user = await User.findOne({ username: credentials.username });
        if (!user) {
            throw new Error('User not found');
        }
        const validPassword = await argon2.verify(user.password, credentials.password);
        if (!validPassword) {
            throw new Error('Invalid password');
        }
        // User authenticated successfully, generate tokens
        // @ts-ignore
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET_KEY, { expiresIn: '1h' });
        // @ts-ignore
        const refreshToken = jwt.sign({ id: user._id }, process.env.JWT_REFRESH_SECRET_KEY, { expiresIn: '7d' });

        return { user, token, refreshToken };
    },


    // User service to automatically refresh the access token
    async refreshAccessToken(refreshToken: string) {
        try {
            // @ts-ignore
            const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET_KEY);
            const user = await User.findById(decoded.id);
            if (!user) {
                throw new Error('User not found');
            }
            // @ts-ignore
            const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET_KEY, { expiresIn: '1h' });
            return { token };
        } catch (error) {
            throw new Error('Invalid refresh token');
        }
    },


    // User service to add a book's ISBN to a user's favorites
    async addToFavorites(userId: string, isbn: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        if (user.favoriteBooks.includes(isbn)) {
            throw new Error('Book already in favorites');
        }
        user.favoriteBooks.push(isbn);
        await user.save();
        return user;
    },


    // User service to remove a book's ISBN from a user's favorites
    async removeFromFavorites(userId: string, isbn: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        const index = user.favoriteBooks.indexOf(isbn);
        if (index === -1) {
            throw new Error('Book not in favorites');
        }
        user.favoriteBooks.splice(index, 1);
        await user.save();
        return user;
    },


    // User service to get the infos of the user's favorite books thanks to their ISBN
    async getFavorites(userId: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        // array to store the favorite books
        const favoriteBooks = [];
        for (const isbn of user.favoriteBooks) {
            // @ts-ignore
            const book = await Book.findOne({ isbn });
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
            throw new Error('User not found');
        }
        return user.ecologicalImpact;
    }
};

export default UserService;
