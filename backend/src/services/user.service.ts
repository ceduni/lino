import User from '../models/user.model';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const UserService = {
    // User service to register a new user's account
    async registerUser(userData: any) {
        const { username, email, phone, password, getAlerted } = userData;
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
            throw new Error('User not found');
        }
        const validPassword = await argon2.verify(user.password, credentials.password);
        if (!validPassword) {
            throw new Error('Invalid password');
        }
        // User authenticated successfully, generate tokens
        // @ts-ignore
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET_KEY);

        return { user: user, token: token };
    },


    // User service to add a book's ID to a user's favorites
    async addToFavorites(userId: string, id: string) {
        let user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        if (user.favoriteBooks.includes(id)) {
            return;
        }
        user.favoriteBooks.push(id);
        await user.save();
        return user;
    },


    // User service to remove a book's ID from a user's favorites
    async removeFromFavorites(userId: string, id: string) {
        let user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        const index = user.favoriteBooks.indexOf(id);
        if (index === -1) {
            return;
        }
        user.favoriteBooks.splice(index, 1);
        await user.save();
        return user;
    },


    // User service to get the infos of the user's favorite books
    async getFavorites(userId: string) {
        let user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
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
    },


   async parseKeyWords(text: string) {
        return text.split(',');
    },

    async updateUser(request: any) {
        const user = await User.findById(request.user.id);
        if (!user) {
            throw new Error('User not found');
        }
        if (request.body.username) {
            const check = await User.findOne({ username: request.body.username });
            if (check) {
                throw new Error('Username already taken');
            }
            user.username = request.body.username;
        }
        if (request.body.password) {
            user.password = await argon2.hash(request.body.password);
        }
        if (request.body.email) {
            const check = await User.findOne({ email: request.body.email });
            if (check) {
                throw new Error('Email already taken');
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
        await User.deleteMany({});
    }
};

export async function notifyUser(userId: string, message: string) {
    let user = await User.findById(userId);
    if (!user) {
        throw new Error('User not found');
    }
    // @ts-ignore
    const notification = { content: message };
    user.notifications.push(notification);
    await user.save();
    return user;
}



export default UserService;
