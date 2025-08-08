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
const models_1 = require("../models");
const argon2_1 = __importDefault(require("argon2"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const dotenv_1 = __importDefault(require("dotenv"));
const utilities_1 = require("../utilities/utilities");
const _1 = require(".");
const borough_id_generator_1 = require("../utilities/borough.id.generator");
dotenv_1.default.config();
const UserService = {
    // User service to register a new user's account
    registerUser(username, email, password, phone) {
        return __awaiter(this, void 0, void 0, function* () {
            if (username === 'guest') {
                throw (0, utilities_1.newErr)(400, 'Username not allowed');
            }
            // Check if username already exists
            if (!username) {
                throw (0, utilities_1.newErr)(400, 'Username is required');
            }
            const existingUser = yield models_1.User.findOne({ username });
            if (existingUser) {
                throw (0, utilities_1.newErr)(400, 'Username already taken');
            }
            // Check if email already exists
            if (!email) {
                throw (0, utilities_1.newErr)(400, 'Email is required');
            }
            const existingEmail = yield models_1.User.findOne({ email });
            if (existingEmail) {
                throw (0, utilities_1.newErr)(400, 'Email already taken');
            }
            if (!password) {
                throw (0, utilities_1.newErr)(400, 'Password is required');
            }
            const hashedPassword = yield argon2_1.default.hash(password);
            const user = new models_1.User({ username: username,
                email: email,
                phone: phone,
                password: hashedPassword
            });
            yield user.save();
            const token = jsonwebtoken_1.default.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY);
            return { username: user.username, email: user.email, token: token };
        });
    },
    // User service to log in a user if they exist (can log with either a username or an email)
    loginUser(identifier, password) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findOne({ $or: [{ username: identifier }, { email: identifier }] });
            if (!user) {
                throw (0, utilities_1.newErr)(400, 'Invalid username or email');
            }
            const validPassword = yield argon2_1.default.verify(user.password, password);
            if (!validPassword) {
                throw (0, utilities_1.newErr)(400, 'Invalid password');
            }
            // User authenticated successfully, generate tokens
            const token = jsonwebtoken_1.default.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY);
            return { username: user.username, email: user.email, token: token };
        });
    },
    getUserNotifications(id) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield _1.NotificationService.getUserNotifications(id);
        });
    },
    readNotification(id, notificationId) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield _1.NotificationService.readNotification(id, notificationId);
        });
    },
    getUserName(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(userId);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            return user.username;
        });
    },
    getUser(id) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            return user;
        });
    },
    updateUser(id, username, password, email, phone, favouriteGenres) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (username) {
                const check = yield models_1.User.findOne({ username: username });
                if (check && check.username !== user.username) {
                    throw (0, utilities_1.newErr)(400, 'Username already taken');
                }
                user.username = username;
            }
            if (password) {
                user.password = yield argon2_1.default.hash(password);
            }
            if (email && email !== user.email) {
                const check = yield models_1.User.findOne({ email: email });
                if (check) {
                    throw (0, utilities_1.newErr)(400, 'Email already taken');
                }
                user.email = email;
            }
            if (phone) {
                user.phone = phone;
            }
            if (favouriteGenres) {
                user.favouriteGenres = favouriteGenres;
            }
            yield user.save();
            return user;
        });
    },
    addUserFavLocation(id, latitude, longitude, name, tag) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (!latitude || !longitude || !name) {
                throw (0, utilities_1.newErr)(400, 'Latitude, longitude and name are required');
            }
            // Get borough ID from coordinates
            const boroughId = yield (0, borough_id_generator_1.getBoroughId)(latitude, longitude);
            user.favouriteLocations.push({
                latitude: latitude,
                longitude: longitude,
                name: name,
                boroughId: boroughId,
                tag: tag // Optional tag for the location
            });
            yield user.save();
            return {
                latitude: latitude,
                longitude: longitude,
                boroughId: boroughId,
                name: name,
                tag: tag // Return the tag if provided
            };
        });
    },
    deleteUserFavLocation(id, name) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (!name) {
                throw (0, utilities_1.newErr)(400, 'Name is required');
            }
            // Find the index of the location to remove
            const index = user.favouriteLocations.findIndex(location => location.name === name);
            if (index === -1) {
                throw (0, utilities_1.newErr)(404, 'Location not found in favourites');
            }
            // Remove the location from the array
            user.favouriteLocations.splice(index, 1);
            yield user.save();
        });
    },
    toggleAcceptedNotificationType(id, type) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield models_1.User.findById(id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (!user.notificationSettings) {
                user.notificationSettings = {
                    addedBook: true,
                    bookRequested: true
                };
            }
            if (type === 'addedBook') {
                user.notificationSettings.addedBook = !user.notificationSettings.addedBook;
            }
            else if (type === 'bookRequested') {
                user.notificationSettings.bookRequested = !user.notificationSettings.bookRequested;
            }
            else {
                throw (0, utilities_1.newErr)(400, 'Invalid notification type');
            }
            yield user.save();
            return user.notificationSettings;
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield models_1.User.deleteMany({ username: { $ne: process.env.ADMIN_USERNAME } });
        });
    },
    clearNotifications() {
        return __awaiter(this, void 0, void 0, function* () {
            yield _1.NotificationService.clearCollection();
            return { message: 'Notifications cleared' };
        });
    }
};
exports.default = UserService;
