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
            const admins = await Admin.find({}, 'username createdAt');
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
    async addNewBookbox(request: any) {
        try {
            const boroughId = await getBoroughId(request.body.latitude, request.body.longitude);
            const bookBox = new BookBox({
                name: request.body.name,
                owner: request.user.username,
                books: [],
                image: request.body.image,
                longitude: request.body.longitude,
                latitude: request.body.latitude,
                boroughId: boroughId,
                infoText: request.body.infoText,
            });
            await bookBox.save();
            return bookBox;
        } catch (error) {
            throw newErr(500, 'Failed to create bookbox');
        }
    },

    async updateBookBox(request: any) {
        try {
            const bookBoxId = request.params.bookboxId;
            const updateData = request.body;
            const bookBox = await BookBox.findById(bookBoxId);
            
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (request.user.username !== process.env.ADMIN_USERNAME && bookBox.owner !== request.user.username) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }

            // Update the bookbox fields if they are provided
            if (updateData.name) {
                bookBox.name = updateData.name;
            }
            if (updateData.image) {
                bookBox.image = updateData.image;
            }
            if (updateData.longitude) {
                bookBox.longitude = updateData.longitude;
            }
            if (updateData.latitude) {
                bookBox.latitude = updateData.latitude;
            }
            if (updateData.latitude || updateData.longitude) {
                // If either latitude or longitude is updated, we need to update the boroughId
                const boroughId = await getBoroughId(updateData.latitude || bookBox.latitude, updateData.longitude || bookBox.longitude);
                bookBox.boroughId = boroughId;
            }
            if (updateData.infoText) {
                bookBox.infoText = updateData.infoText;
            }
            
            await bookBox.save();

            return {
                _id: bookBox._id.toString(),
                name: bookBox.name,
                image: bookBox.image,
                longitude: bookBox.longitude,
                latitude: bookBox.latitude,
                boroughId: bookBox.boroughId,
                infoText: bookBox.infoText
            };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to update bookbox');
        }
    },

    async deleteBookBox(request: any) {
        try {
            const bookBox = await BookBox.findById(request.params.bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (request.user.username !== process.env.ADMIN_USERNAME && bookBox.owner !== request.user.username) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }

            await BookBox.findByIdAndDelete(request.params.bookboxId);
            
            // Delete all transactions related to this bookbox
            await Transaction.deleteMany({ bookboxId: request.params.bookboxId });

            return { message: 'Bookbox deleted successfully' };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to delete bookbox');
        }
    },

    async deactivateBookBox(request: any) {
        try {
            const bookBox = await BookBox.findById(request.params.bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (request.user.username !== process.env.ADMIN_USERNAME && bookBox.owner !== request.user.username) {
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

    async transferBookBoxOwnership(request: any) {
        try {            
            const bookBox = await BookBox.findById(request.params.bookboxId);
            if (!bookBox) {
                throw newErr(404, 'Bookbox not found');
            }

            // Check ownership (super admin or owner)
            if (request.user.username !== process.env.ADMIN_USERNAME && bookBox.owner !== request.user.username) {
                throw newErr(401, 'Unauthorized: You can only manage your own bookboxes');
            }

            const { newOwner } = request.body;
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
