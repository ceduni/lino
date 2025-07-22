import Admin from './admin.model';
import { newErr } from "../services/utilities";
import User from '../users/user.model';
import { getBoroughId } from '../services/borough.id.generator';
import BookBox from '../bookboxes/bookbox.model';
import Transaction from '../transactions/transaction.model';

const AdminService = {
    // Add a user to the admin list
    async addAdmin(username: string) {
        try {
            const existingAdmin = await Admin.findOne({ username });
            if (existingAdmin) {
                throw newErr(400, 'User is already an admin');
            }

            // Verify that the username exists in the User collection
            const userExists = await User.findOne({ username });
            if (!userExists) {
                throw newErr(404, 'User not found');
            }
            
            const admin = new Admin({ username });
            await admin.save();
            return admin;
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to add admin');
        }
    },

    async trySetAdmin(
        username: string,
        adminKey: string,
    ) {
        try {

            // Check if the provided key matches the admin key
            if (adminKey !== process.env.ADMIN_VERIFICATION_KEY) {
                throw newErr(403, 'Invalid admin key');
            }

            const admin = await this.addAdmin(username);
            return { message: 'Admin added successfully', admin };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to set admin');
        }
    },

    // Check if a user is an admin
    async isAdmin(username: string): Promise<boolean> {
        try {
            const admin = await Admin.findOne({ username });
            return !!admin;
        } catch (error) {
            return false;
        }
    },

    // Remove a user from the admin list
    async removeAdmin(username: string) {
        try {
            const result = await Admin.deleteOne({ username });
            if (result.deletedCount === 0) {
                throw newErr(404, 'Admin not found');
            }
            return { message: 'Admin removed successfully' };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to remove admin');
        }
    },

    // Get all admins
    async getAllAdmins() {
        try {
            const admins = await Admin.find();
            return admins;
        } catch (error) {
            throw newErr(500, 'Failed to retrieve admins');
        }
    },

    // Clear all admins (for testing purposes)
    async clearAdmins() {
        try {
            await Admin.deleteMany({});
            return { message: 'All admins cleared' };
        } catch (error) {
            throw newErr(500, 'Failed to clear admins');
        }
    },

    // Bookbox Management Functions
    async addNewBookbox(
        owner: string,
        name: string,
        latitude: number,
        longitude: number,
        image: string,
        infoText?: string
    ) {
        try {
            const boroughId = await getBoroughId(latitude, longitude);
            const bookBox = new BookBox({
                name,
                owner,
                books: [],
                image,
                longitude,
                latitude,
                boroughId,
                infoText
            });
            await bookBox.save();
            return bookBox;
        } catch (error) {
            throw newErr(500, 'Failed to create bookbox');
        }
    },
    

    async updateBookBox(
        owner: string,
        bookboxId: string,
        name?: string,
        image?: string,
        latitude?: number,
        longitude?: number,
        infoText?: string
    ) {
        try {
            const bookBox = await BookBox.findById(bookboxId);

            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
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
                const boroughId = await getBoroughId(latitude || bookBox.latitude, longitude || bookBox.longitude);
                bookBox.boroughId = boroughId;
            }
            if (infoText) {
                bookBox.infoText = infoText;
            }
            
            await bookBox.save();

            return bookBox;
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to update bookbox');
        }
    },

    async deleteBookBox(
        owner: string,
        bookboxId: string
    ) {
        try {
            const bookBox = await BookBox.findById(bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }

            await BookBox.findByIdAndDelete(bookboxId);

            // Delete all transactions related to this bookbox
            await Transaction.deleteMany({ bookboxId });

            return { message: 'Bookbox deleted successfully' };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to delete bookbox');
        }
    },

    async activateBookBox(
        owner: string,
        bookboxId: string
    ) {
        try {
            const bookBox = await BookBox.findById(bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }
            // Check ownership (super admin or owner)
            if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }   
            bookBox.isActive = true;
            await bookBox.save();
            return {
                message: 'Bookbox activated successfully',
                bookbox: {
                    _id: bookBox._id.toString(),
                    name: bookBox.name,
                    isActive: bookBox.isActive
                }
            };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to activate bookbox');
        }
    },

    async deactivateBookBox(
        owner: string,
        bookboxId: string
    ) {
        try {
            const bookBox = await BookBox.findById(bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }

            bookBox.isActive = false;
            await bookBox.save();

            return {
                message: 'Bookbox deactivated successfully',
                bookbox: {
                    _id: bookBox._id.toString(),
                    name: bookBox.name,
                    isActive: bookBox.isActive
                }
            };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to deactivate bookbox');
        }
    },

    async transferBookBoxOwnership(
        owner: string,
        bookboxId: string,
        newOwner: string
    ) {
        try {
            const bookBox = await BookBox.findById(bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (owner !== process.env.ADMIN_USERNAME && bookBox.owner !== owner) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }

            if (!newOwner) {
                throw newErr(400, 'New owner username is required');
            }

            // Check if new owner exists and is an admin
            const isNewOwnerAdmin = await this.isAdmin(newOwner);
            if (!isNewOwnerAdmin) {
                throw newErr(400, 'New owner must be an admin');
            }

            bookBox.owner = newOwner;
            await bookBox.save();

            return {
                message: 'Bookbox ownership transferred successfully',
                bookbox: {
                    _id: bookBox._id.toString(),
                    name: bookBox.name,
                    owner: bookBox.owner
                }
            };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to transfer bookbox ownership');
        }
    }
};

export default AdminService;
