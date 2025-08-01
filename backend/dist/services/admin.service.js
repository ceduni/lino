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
Object.defineProperty(exports, "__esModule", { value: true });
const utilities_1 = require("../utilities/utilities");
const models_1 = require("../models");
const borough_id_generator_1 = require("../utilities/borough.id.generator");
const AdminService = {
    // Add a user to the admin list
    addAdmin(username) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Verify that the username exists in the User collection
                const user = yield models_1.User.findOne({ username });
                if (!user) {
                    throw (0, utilities_1.newErr)(404, 'User not found');
                }
                if (user.isAdmin) {
                    throw (0, utilities_1.newErr)(400, 'User is already an admin');
                }
                // Set isAdmin to true
                user.isAdmin = true;
                yield user.save();
                return {
                    username: user.username,
                    createdAt: new Date().toISOString()
                };
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to add admin');
            }
        });
    },
    // Check if a user is an admin
    isAdmin(username) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const user = yield models_1.User.findOne({ username });
                return user ? user.isAdmin : false;
            }
            catch (error) {
                return false;
            }
        });
    },
    // Remove a user from the admin list
    removeAdmin(username) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const user = yield models_1.User.findOne({ username });
                if (!user) {
                    throw (0, utilities_1.newErr)(404, 'User not found');
                }
                if (!user.isAdmin) {
                    throw (0, utilities_1.newErr)(404, 'User is not an admin');
                }
                user.isAdmin = false;
                yield user.save();
                return { message: 'Admin removed successfully' };
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to remove admin');
            }
        });
    },
    // Get all admins
    searchAdmins(username_1, q_1) {
        return __awaiter(this, arguments, void 0, function* (username, q, limit = 20, page = 1) {
            try {
                const pageSize = limit;
                const skip = (page - 1) * pageSize;
                // Start with users who have isAdmin = true and skip our own username
                const query = {
                    isAdmin: true,
                    username: { $ne: username }
                };
                if (q) {
                    query.$and = [
                        { isAdmin: true },
                        { username: { $ne: username } },
                        { username: { $regex: q, $options: 'i' } }
                    ];
                }
                const users = yield models_1.User.find(query)
                    .select('username createdAt')
                    .skip(skip)
                    .limit(pageSize);
                const total = yield models_1.User.countDocuments(query);
                const totalPages = Math.ceil(total / pageSize);
                // Transform users to match the expected admin format
                const admins = users.map(user => ({
                    _id: user._id,
                    username: user.username,
                    createdAt: user.createdAt
                }));
                return {
                    admins,
                    pagination: {
                        currentPage: page,
                        totalPages,
                        totalResults: total,
                        hasNextPage: page < totalPages,
                        hasPrevPage: page > 1,
                        limit: pageSize
                    }
                };
            }
            catch (error) {
                throw (0, utilities_1.newErr)(500, 'Failed to retrieve admins');
            }
        });
    },
    // Clear all admins (for testing purposes)
    clearAdmins() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield models_1.User.updateMany({ isAdmin: true }, { isAdmin: false });
                return { message: 'All admins cleared' };
            }
            catch (error) {
                throw (0, utilities_1.newErr)(500, 'Failed to clear admins');
            }
        });
    },
    // Bookbox Management Functions
    addNewBookbox(_a) {
        return __awaiter(this, arguments, void 0, function* ({ owner, name, latitude, longitude, image, infoText }) {
            try {
                const boroughId = yield (0, borough_id_generator_1.getBoroughId)(latitude, longitude);
                const bookBox = new models_1.BookBox({
                    name,
                    owner,
                    books: [],
                    image,
                    longitude,
                    latitude,
                    boroughId,
                    infoText
                });
                yield bookBox.save();
                return bookBox;
            }
            catch (error) {
                throw (0, utilities_1.newErr)(500, 'Failed to create bookbox');
            }
        });
    },
    updateBookBox(_a) {
        return __awaiter(this, arguments, void 0, function* ({ owner, bookboxId, name, image, latitude, longitude, infoText }) {
            try {
                const bookBox = yield models_1.BookBox.findById(bookboxId);
                if (!bookBox) {
                    throw (0, utilities_1.newErr)(404, 'Bookbox not found');
                }
                // Check ownership (super admin or owner)
                if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                    throw (0, utilities_1.newErr)(401, 'Unauthorized: You can only manage your own bookboxes');
                }
                // Update the bookbox fields if they are provided
                if (name) {
                    bookBox.name = name;
                }
                if (image) {
                    bookBox.image = image;
                }
                if (longitude) {
                    bookBox.longitude = longitude;
                }
                if (latitude) {
                    bookBox.latitude = latitude;
                }
                if (latitude || longitude) {
                    // If either latitude or longitude is updated, we need to update the boroughId
                    const boroughId = yield (0, borough_id_generator_1.getBoroughId)(latitude || bookBox.latitude, longitude || bookBox.longitude);
                    bookBox.boroughId = boroughId;
                }
                if (infoText) {
                    bookBox.infoText = infoText;
                }
                yield bookBox.save();
                return bookBox;
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to update bookbox');
            }
        });
    },
    deleteBookBox(owner, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const bookBox = yield models_1.BookBox.findById(bookboxId);
                if (!bookBox) {
                    throw (0, utilities_1.newErr)(404, 'Bookbox not found');
                }
                // Check ownership (super admin or owner)
                if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                    throw (0, utilities_1.newErr)(401, 'Unauthorized: You can only manage your own bookboxes');
                }
                yield models_1.BookBox.findByIdAndDelete(bookboxId);
                // Delete all transactions related to this bookbox
                yield models_1.Transaction.deleteMany({ bookboxId });
                return { message: 'Bookbox deleted successfully' };
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to delete bookbox');
            }
        });
    },
    activateBookBox(owner, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const bookBox = yield models_1.BookBox.findById(bookboxId);
                if (!bookBox) {
                    throw (0, utilities_1.newErr)(404, 'Bookbox not found');
                }
                // Check ownership (super admin or owner)
                if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                    throw (0, utilities_1.newErr)(401, 'Unauthorized: You can only manage your own bookboxes');
                }
                bookBox.isActive = true;
                yield bookBox.save();
                return {
                    message: 'Bookbox activated successfully',
                    bookbox: {
                        _id: bookBox._id.toString(),
                        name: bookBox.name,
                        isActive: bookBox.isActive
                    }
                };
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to activate bookbox');
            }
        });
    },
    deactivateBookBox(owner, bookboxId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const bookBox = yield models_1.BookBox.findById(bookboxId);
                if (!bookBox) {
                    throw (0, utilities_1.newErr)(404, 'Bookbox not found');
                }
                // Check ownership (super admin or owner)
                if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                    throw (0, utilities_1.newErr)(401, 'Unauthorized: You can only manage your own bookboxes');
                }
                bookBox.isActive = false;
                yield bookBox.save();
                return {
                    message: 'Bookbox deactivated successfully',
                    bookbox: {
                        _id: bookBox._id.toString(),
                        name: bookBox.name,
                        isActive: bookBox.isActive
                    }
                };
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to deactivate bookbox');
            }
        });
    },
    transferBookBoxOwnership(owner, bookboxId, newOwner) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const bookBox = yield models_1.BookBox.findById(bookboxId);
                if (!bookBox) {
                    throw (0, utilities_1.newErr)(404, 'Bookbox not found');
                }
                // Check ownership (super admin or owner)
                if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                    throw (0, utilities_1.newErr)(401, 'Unauthorized: You can only manage your own bookboxes');
                }
                if (!newOwner) {
                    throw (0, utilities_1.newErr)(400, 'New owner username is required');
                }
                // Check if new owner exists and is an admin
                const isNewOwnerAdmin = yield this.isAdmin(newOwner);
                if (!isNewOwnerAdmin) {
                    throw (0, utilities_1.newErr)(400, 'New owner must be an admin');
                }
                bookBox.owner = newOwner;
                yield bookBox.save();
                return {
                    message: 'Bookbox ownership transferred successfully',
                    bookbox: {
                        _id: bookBox._id.toString(),
                        name: bookBox.name,
                        owner: bookBox.owner
                    }
                };
            }
            catch (error) {
                if (error.statusCode) {
                    throw error;
                }
                throw (0, utilities_1.newErr)(500, 'Failed to transfer bookbox ownership');
            }
        });
    }
};
exports.default = AdminService;
