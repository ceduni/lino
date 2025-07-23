import { newErr } from "../services/utilities";
import User from '../users/user.model';
import { getBoroughId } from '../services/borough.id.generator';
import BookBox from '../bookboxes/bookbox.model';
import Transaction from '../transactions/transaction.model';

const AdminService = {
    // Add a user to the admin list
    async addAdmin(username: string) {
        try {
            // Verify that the username exists in the User collection
            const user = await User.findOne({ username });
            if (!user) {
                throw newErr(404, 'User not found');
            }

            if (user.isAdmin) {
                throw newErr(400, 'User is already an admin');
            }
            
            // Set isAdmin to true
            user.isAdmin = true;
            await user.save();
            
            return {
                username: user.username,
                createdAt: new Date().toISOString()
            };
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
            const user = await User.findOne({ username });
            return user ? user.isAdmin : false;
        } catch (error) {
            return false;
        }
    },

    // Remove a user from the admin list
    async removeAdmin(username: string) {
        try {
            const user = await User.findOne({ username });
            if (!user) {
                throw newErr(404, 'User not found');
            }

            if (!user.isAdmin) {
                throw newErr(404, 'User is not an admin');
            }

            user.isAdmin = false;
            await user.save();
            
            return { message: 'Admin removed successfully' };
        } catch (error) {
            if ((error as any).statusCode) {
                throw error;
            }
            throw newErr(500, 'Failed to remove admin');
        }
    },

    // Get all admins
    async searchAdmins(
        username: string,
        q?: string,
        limit: number = 20,
        page: number = 1
    ) {
        try {
            const pageSize = limit;
            const skip = (page - 1) * pageSize;
            
            // Start with users who have isAdmin = true and skip our own username
            const query: any = { 
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

            const users = await User.find(query)
                .select('username createdAt')
                .skip(skip)
                .limit(pageSize);
            
            const total = await User.countDocuments(query);

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
        } catch (error) {
            throw newErr(500, 'Failed to retrieve admins');
        }
    },

    // Clear all admins (for testing purposes)
    async clearAdmins() {
        try {
            await User.updateMany({ isAdmin: true }, { isAdmin: false });
            return { message: 'All admins cleared' };
        } catch (error) {
            throw newErr(500, 'Failed to clear admins');
        }
    },

    // Bookbox Management Functions
    async addNewBookbox({
        owner,
        name,
        latitude,
        longitude,
        image,
        infoText
    }: {
        owner: string;
        name: string;
        latitude: number;
        longitude: number;
        image: string;
        infoText?: string;
    }) {
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
    

    async updateBookBox({
        owner,
        bookboxId,
        name,
        image,
        latitude,
        longitude,
        infoText
    }: {
        owner: string;
        bookboxId: string;
        name?: string;
        image?: string;
        latitude?: number;
        longitude?: number;
        infoText?: string;
    }) {
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
