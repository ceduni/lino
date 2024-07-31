"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.notifyUser = void 0;
const user_model_1 = __importDefault(require("../models/user.model"));
const argon2_1 = __importDefault(require("argon2"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const dotenv_1 = __importDefault(require("dotenv"));
const utilities_1 = require("./utilities");
dotenv_1.default.config();
const UserService = {
    // User service to register a new user's account
    registerUser(userData) {
        return __awaiter(this, void 0, void 0, function* () {
            const { username, email, phone, password, getAlerted } = userData;
            if (username === 'guest') {
                throw (0, utilities_1.newErr)(400, 'Username not allowed');
            }
            // Check if username already exists
            if (!username) {
                throw (0, utilities_1.newErr)(400, 'Username is required');
            }
            const existingUser = yield user_model_1.default.findOne({ username });
            if (existingUser) {
                throw (0, utilities_1.newErr)(400, 'Username already taken');
            }
            // Check if email already exists
            if (!email) {
                throw (0, utilities_1.newErr)(400, 'Email is required');
            }
            const existingEmail = yield user_model_1.default.findOne({ email });
            if (existingEmail) {
                throw (0, utilities_1.newErr)(400, 'Email already taken');
            }
            if (!password) {
                throw (0, utilities_1.newErr)(400, 'Password is required');
            }
            const hashedPassword = yield argon2_1.default.hash(password);
            const user = new user_model_1.default({ username: username,
                email: email,
                phone: phone,
                password: hashedPassword,
                getAlerted: getAlerted
            });
            yield user.save();
            return { username: user.username, password: user.password };
        });
    },
    // User service to log in a user if they exist (can log with either a username or an email)
    loginUser(credentials) {
        return __awaiter(this, void 0, void 0, function* () {
            const identifier = credentials.identifier;
            const user = yield user_model_1.default.findOne({ $or: [{ username: identifier }, { email: identifier }] });
            if (!user) {
                throw (0, utilities_1.newErr)(400, 'Invalid username or email');
            }
            const validPassword = yield argon2_1.default.verify(user.password, credentials.password);
            if (!validPassword) {
                throw (0, utilities_1.newErr)(400, 'Invalid password');
            }
            // User authenticated successfully, generate tokens
            // @ts-ignore
            const token = jsonwebtoken_1.default.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY);
            return { user: user, token: token };
        });
    },
    readUserNotifications(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const userId = request.user.id;
            const user = yield user_model_1.default.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
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
            yield user.save();
            return user.notifications;
        });
    },
    // User service to add a book's ID to a user's favorites
    addToFavorites(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const userId = request.user.id; // Extract user ID from JWT token
            const bookId = request.body.bookId;
            let user = yield user_model_1.default.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (user.favoriteBooks.includes(bookId)) {
                throw (0, utilities_1.newErr)(400, 'Book already in favorites');
            }
            user.favoriteBooks.push(bookId);
            yield user.save();
            return user;
        });
    },
    // User service to remove a book's ID from a user's favorites
    removeFromFavorites(request) {
        return __awaiter(this, void 0, void 0, function* () {
            // @ts-ignore
            const userId = request.user.id; // Extract user ID from JWT token
            // @ts-ignore
            const id = request.params.id;
            let user = yield user_model_1.default.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const index = user.favoriteBooks.indexOf(id);
            if (index === -1) { // Book not found in favorites
                throw (0, utilities_1.newErr)(404, 'Book not found in favorites');
            }
            user.favoriteBooks.splice(index, 1);
            yield user.save();
            return user;
        });
    },
    // User service to get the infos of the user's favorite books
    getFavorites(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            let user = yield user_model_1.default.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            // array to store the favorite books
            const favoriteBooks = [];
            for (const bookId of user.favoriteBooks) {
                // @ts-ignore
                const book = yield Book.findById(bookId);
                if (book) {
                    favoriteBooks.push(book);
                }
            }
            return favoriteBooks;
        });
    },
    // User service to get the user's ecological impact
    getEcologicalImpact(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            return user.ecologicalImpact;
        });
    },
    getUserName(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            return user.username;
        });
    },
    parseKeyWords(text) {
        return __awaiter(this, void 0, void 0, function* () {
            return text.split(',');
        });
    },
    updateUser(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(request.user.id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (request.body.username) {
                const check = yield user_model_1.default.findOne({ username: request.body.username });
                if (check) {
                    throw (0, utilities_1.newErr)(400, 'Username already taken');
                }
                user.username = request.body.username;
            }
            if (request.body.password) {
                user.password = yield argon2_1.default.hash(request.body.password);
            }
            if (request.body.email) {
                const check = yield user_model_1.default.findOne({ email: request.body.email });
                if (check) {
                    throw (0, utilities_1.newErr)(400, 'Email already taken');
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
                user.notificationKeyWords = yield this.parseKeyWords(request.body.keyWords);
            }
            yield user.save();
            return user;
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield user_model_1.default.deleteMany({ username: { $ne: process.env.ADMIN_USERNAME } });
        });
    }
};
function notifyUser(userId, title, message) {
    return __awaiter(this, void 0, void 0, function* () {
        let user = yield user_model_1.default.findById(userId);
        if (!user) {
            throw (0, utilities_1.newErr)(404, 'User not found');
        }
        const notification = { title: title, content: message, timestamp: new Date(), read: false };
        // Validate and push the notification into the user's notifications array
        try {
            user.notifications.push(notification); // Type assertion to avoid TypeScript errors
            yield user.save();
        }
        catch (error) {
            throw new Error(`Failed to save notification: ${error.message}`);
        }
        return user;
    });
}
exports.notifyUser = notifyUser;
exports.default = UserService;
