import User from '../models/user.model';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const UserService = {
    // User service to register a new user's account
    async registerUser(userData: any) {
        const { username, email, phone, password } = userData;
        if (username === 'guest') {
            throw new Error('Username not allowed');
        }

        // Check if username already exists
        const existingUser = await User.findOne({ username });
        if (existingUser) {
            throw new Error('Username already taken');
        }
        // Check if email already exists
        const existingEmail = await User.findOne({ email });
        if (existingEmail) {
            throw new Error('Email already taken');
        }

        const hashedPassword = await argon2.hash(password);
        const user = new User(
            { username : username,
                email : email,
                phone : phone,
                password: hashedPassword });
        await user.save();
        return user;
    },

    // User service to log in a user if they exist (can log with either a username or an email)
    async loginUser(credentials: any) {
        const identifier = credentials.identifier;
        console.log(credentials.identifier);
        const user = await User.findOne({ $or: [{ username : identifier }, { email : identifier }]});
        if (!user) {
            throw new Error('User not found');
        }
        const validPassword = await argon2.verify(user.password, credentials.password);
        if (!validPassword) {
            throw new Error('Invalid password');
        }
        // User authenticated successfully, generate tokens
        // @ts-ignore
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET_KEY);

        return { user, token };
    },


    // User service to add a book's ISBN to a user's favorites
    async addToFavorites(userId: string, id: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        if (user.favoriteBooks.includes(id)) {
            throw new Error('Book already in favorites');
        }
        user.favoriteBooks.push(id);
        await user.save();
        return user;
    },


    // User service to remove a book's ISBN from a user's favorites
    async removeFromFavorites(userId: string, id: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        const index = user.favoriteBooks.indexOf(id);
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
    },

    async getUserName(userId: string) {
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        return user.username;
    }
};

export default UserService;
