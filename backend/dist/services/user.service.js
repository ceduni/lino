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
const user_model_1 = __importDefault(require("../models/user.model"));
const argon2_1 = __importDefault(require("argon2"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const dotenv_1 = __importDefault(require("dotenv"));
const utilities_1 = require("./utilities");
const notification_service_1 = __importDefault(require("./notification.service"));
const borough_id_generator_1 = require("./borough.id.generator");
dotenv_1.default.config();
const UserService = {
    // User service to register a new user's account
    registerUser(userData) {
        return __awaiter(this, void 0, void 0, function* () {
            const { username, email, phone, password } = userData;
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
                password: hashedPassword
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
            const token = jsonwebtoken_1.default.sign({ id: user._id, username: user.username }, process.env.JWT_SECRET_KEY);
            return { user: user, token: token };
        });
    },
    getUserNotifications(request) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield notification_service_1.default.getUserNotifications(request);
        });
    },
    readNotification(request) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield notification_service_1.default.readNotification(request);
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
    updateUser(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(request.user.id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            if (request.body.username) {
                const check = yield user_model_1.default.findOne({ username: request.body.username });
                if (check && check.username !== user.username) {
                    throw (0, utilities_1.newErr)(400, 'Username already taken');
                }
                user.username = request.body.username;
            }
            if (request.body.password) {
                user.password = yield argon2_1.default.hash(request.body.password);
            }
            if (request.body.email && request.body.email !== user.email) {
                const check = yield user_model_1.default.findOne({ email: request.body.email });
                if (check) {
                    throw (0, utilities_1.newErr)(400, 'Email already taken');
                }
                user.email = request.body.email;
            }
            if (request.body.phone) {
                user.phone = request.body.phone;
            }
            if (request.body.favouriteGenres) {
                user.favouriteGenres = request.body.favouriteGenres;
            }
            if (request.body.boroughId) {
                user.boroughId = request.body.boroughId;
            }
            if (request.body.requestNotificationRadius !== undefined) {
                user.requestNotificationRadius = request.body.requestNotificationRadius;
            }
            yield user.save();
            return user;
        });
    },
    updateUserLocation(request) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield user_model_1.default.findById(request.user.id);
            if (!user) {
                throw (0, utilities_1.newErr)(404, 'User not found');
            }
            const { latitude, longitude } = request.body;
            if (!latitude || !longitude) {
                throw (0, utilities_1.newErr)(400, 'Latitude and longitude are required');
            }
            // Get borough ID from coordinates
            const boroughId = yield (0, borough_id_generator_1.getBoroughId)(latitude, longitude);
            user.boroughId = boroughId;
            yield user.save();
            return { user, boroughId };
        });
    },
    clearCollection() {
        return __awaiter(this, void 0, void 0, function* () {
            yield user_model_1.default.deleteMany({ username: { $ne: process.env.ADMIN_USERNAME } });
        });
    }
};
exports.default = UserService;
