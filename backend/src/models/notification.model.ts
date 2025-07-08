import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    bookId: { type: mongoose.Schema.Types.ObjectId }, // Optional for book requests
    bookTitle: { type: String }, // Optional for book requests
    bookboxId: { type: mongoose.Schema.Types.ObjectId, ref: 'BookBox' }, // Optional for book requests
    reason: { 
        type: [String], 
        required: true,
        validate: {
            validator: function(reasons: string[]) {
                const validReasons = ['fav_bookbox', 'same_borough', 'fav_genre', 'book_request'];
                return reasons.length > 0 && reasons.every(reason => validReasons.includes(reason));
            },
            message: 'Reason must contain at least one of: fav_bookbox, same_borough, fav_genre, book_request'
        }
    },
    read: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now }
});

// Add indexes for better query performance
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, read: 1 });
notificationSchema.index({ createdAt: 1 }); // For TTL or cleanup operations
notificationSchema.index({ bookboxId: 1 }); // For bookbox-related queries
notificationSchema.index({ reason: 1 }); // For filtering by notification type

const Notification = mongoose.model('Notification', notificationSchema, 'notifications');

export default Notification;
